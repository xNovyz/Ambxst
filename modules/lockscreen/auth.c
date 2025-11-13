#define _GNU_SOURCE
#include <security/pam_appl.h>
#include <security/pam_misc.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include <poll.h>

#define PASS_MAX 512
#define TIMEOUT_MS 15000 // 15 seconds

// Secure memory zeroing
#if defined(__GLIBC__) && (__GLIBC__ > 2 || (__GLIBC__ == 2 && __GLIBC_MINOR__ >= 25))
#define secure_bzero explicit_bzero
#else
static void secure_bzero(void *p, size_t n) {
    volatile unsigned char *vp = p;
    while (n--) *vp++ = 0;
}
#endif

struct auth_data {
    char password[PASS_MAX];
};

// Capture PAM messages (ERROR_MSG, TEXT_INFO)
static char pam_msg_buffer[1024];

static void append_pam_msg(const char *msg) {
    if (!msg) return;
    size_t cur = strlen(pam_msg_buffer);
    size_t remaining = sizeof(pam_msg_buffer) - cur - 1;
    if (remaining > 0)
        strncat(pam_msg_buffer, msg, remaining);
}

static int conv_func(int num_msg, const struct pam_message **msg,
                     struct pam_response **resp, void *appdata_ptr)
{
    struct auth_data *data = (struct auth_data *)appdata_ptr;
    struct pam_response *reply = calloc(num_msg, sizeof(struct pam_response));
    if (!reply) return PAM_CONV_ERR;

    for (int i = 0; i < num_msg; i++) {
        switch (msg[i]->msg_style) {

            case PAM_PROMPT_ECHO_OFF:
            case PAM_PROMPT_ECHO_ON:
                reply[i].resp = strdup(data->password);
                break;

            case PAM_ERROR_MSG:
            case PAM_TEXT_INFO:
                append_pam_msg(msg[i]->msg);
                reply[i].resp = NULL;
                break;

            default:
                free(reply);
                return PAM_CONV_ERR;
        }
    }

    *resp = reply;
    return PAM_SUCCESS;
}

int main(int argc, char *argv[])
{
    if (argc != 2) {
        return 100; // invalid parameters
    }

    const char *user = argv[1];

    struct auth_data data;
    memset(&data, 0, sizeof(data));
    memset(pam_msg_buffer, 0, sizeof(pam_msg_buffer));

    // Read timeout
    struct pollfd pfd = {
        .fd = STDIN_FILENO,
        .events = POLLIN
    };

    int poll_result = poll(&pfd, 1, TIMEOUT_MS);

    if (poll_result == 0)
        return 103; // timeout

    if (poll_result < 0)
        return 104; // error in poll()

    if (!fgets(data.password, PASS_MAX, stdin))
        return 101; // failed reading password

    data.password[strcspn(data.password, "\n")] = '\0';

    pam_handle_t *pamh = NULL;
    struct pam_conv conv = { conv_func, &data };

    int start_ret = pam_start("login", user, &conv, &pamh);
    if (start_ret != PAM_SUCCESS) {
        secure_bzero(data.password, PASS_MAX);
        return 102; // error initializing PAM
    }

    //
    // 1) Authentication
    //
    int auth_ret = pam_authenticate(pamh, 0);

    if (auth_ret == PAM_USER_UNKNOWN) {
        secure_bzero(data.password, PASS_MAX);
        pam_end(pamh, auth_ret);
        return 10;
    }

    if (auth_ret == PAM_AUTH_ERR) {
        // Could be incorrect password
        // Or the start of FAILLOCK failure
        // We don't return yet: verify state in acct_mgmt
    }
    else if (auth_ret != PAM_SUCCESS) {
        secure_bzero(data.password, PASS_MAX);
        pam_end(pamh, auth_ret);
        return 12;
    }

    //
    // 2) Account state
    //
    int acct_ret = pam_acct_mgmt(pamh, 0);

    // --- FAILLOCK DETECTION ---
    // Correct password BUT acct_mgmt returns PERM_DENIED
    if (auth_ret == PAM_SUCCESS && acct_ret == PAM_PERM_DENIED) {
        secure_bzero(data.password, PASS_MAX);
        pam_end(pamh, acct_ret);
        return 30; // FAILLOCK
    }

    // Incorrect password (not faillock)
    if (auth_ret == PAM_AUTH_ERR && acct_ret != PAM_PERM_DENIED) {
        secure_bzero(data.password, PASS_MAX);
        pam_end(pamh, auth_ret);
        return 11;
    }

    // Generic account locked (not faillock)
    if (acct_ret == PAM_PERM_DENIED) {
        secure_bzero(data.password, PASS_MAX);
        pam_end(pamh, acct_ret);
        return 22;
    }

    // Expired account
    if (acct_ret == PAM_ACCT_EXPIRED) {
        secure_bzero(data.password, PASS_MAX);
        pam_end(pamh, acct_ret);
        return 20;
    }

    // Must change password
    if (acct_ret == PAM_NEW_AUTHTOK_REQD) {
        secure_bzero(data.password, PASS_MAX);
        pam_end(pamh, acct_ret);
        return 21;
    }

    if (acct_ret != PAM_SUCCESS) {
        secure_bzero(data.password, PASS_MAX);
        pam_end(pamh, acct_ret);
        return 23; // other error
    }

    // OK
    secure_bzero(data.password, PASS_MAX);
    pam_end(pamh, PAM_SUCCESS);
    return 0;
}
