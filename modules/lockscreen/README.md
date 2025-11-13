# Lockscreen con Autenticación PAM

Este módulo implementa un lockscreen con autenticación PAM real para Ambxst.

## Componentes

### `auth.c` - Binario de autenticación PAM
Binario en C que maneja la autenticación usando PAM (Pluggable Authentication Modules).

**Características:**
- Autenticación segura contra el sistema PAM
- Limpieza segura de contraseñas en memoria (`secure_bzero`)
- Timeout de 15 segundos para entrada de contraseña
- Códigos de retorno detallados para diferentes errores

**Códigos de retorno:**
- `0`: Autenticación exitosa
- `10`: Usuario no encontrado
- `11`: Contraseña incorrecta
- `12`: Error genérico de autenticación
- `20`: Cuenta expirada
- `21`: Necesita cambiar contraseña
- `22`: Cuenta bloqueada (genérica)
- `23`: Otro error de estado de cuenta
- `30`: **Cuenta bloqueada por faillock** (contraseña correcta pero demasiados intentos fallidos)
- `100`: Parámetro inválido
- `101`: Error leyendo contraseña
- `102`: Error inicializando PAM
- `103`: Timeout esperando contraseña
- `104`: Error en poll()

### `pam-auth-stdin.sh` - Wrapper del binario PAM
Script bash que facilita la integración con QuickShell usando variables de entorno.

**Uso:**
```bash
PAM_USER="username" PAM_PASSWORD="password" ./pam-auth-stdin.sh
```

### `LockScreen.qml` - Interfaz del lockscreen
Componente QML que presenta la interfaz visual y maneja la interacción.

**Características:**
- Blur animado del contenido de pantalla
- Campo de contraseña con avatar de usuario
- Mensajes de error específicos según código PAM
- **Detección de faillock con countdown en tiempo real**
- Animación de "shake" en contraseña incorrecta
- Escape con tecla Esc (por ahora, para desarrollo)

## Compilación

```bash
cd modules/lockscreen
./build.sh
```

O manualmente:
```bash
gcc -o pam-auth auth.c -lpam -Wall -Wextra -O2
```

## Uso

El lockscreen se activa automáticamente cuando `GlobalStates.lockscreenVisible` es `true`.

La autenticación funciona de la siguiente manera:
1. Usuario ingresa contraseña
2. Se almacena temporalmente en `authPasswordHolder.password`
3. Se ejecuta `pam-auth-stdin.sh` con variables de entorno PAM_USER y PAM_PASSWORD
4. El script pasa la contraseña por stdin al binario PAM
5. El binario detecta faillock comparando `auth_ret` y `acct_ret`
6. El proceso retorna código de salida
7. QML interpreta el código y muestra mensaje apropiado
8. Si es código 30 (faillock), se ejecuta `faillock --user` para obtener tiempo restante
9. Un timer actualiza el countdown cada segundo
10. La contraseña se limpia inmediatamente de memoria

## Permisos

El binario PAM necesita permisos para autenticar usuarios. En desarrollo típicamente funciona directamente. Para producción, considere:

- Configurar sudo sin contraseña para el binario
- Usar capabilities de Linux (`setcap`)
- Configurar el archivo PAM `/etc/pam.d/login` si es necesario

## Seguridad

- Las contraseñas se limpian de memoria inmediatamente después de usarse (tanto en C como en QML)
- No se almacenan contraseñas en ningún lugar persistente
- El proceso PAM maneja timeout automático
- Variables de entorno se usan solo durante la ejecución del proceso hijo
- La contraseña nunca aparece en argumentos de comando (no visible en `ps`)

## Desarrollo

Para pruebas rápidas durante desarrollo:
- Presionar `Esc` desbloquea sin autenticación
- Revisar console.warn() para mensajes de error PAM

## Detección de Faillock

El sistema detecta bloqueos por faillock de forma inteligente:

**En el binario C (`auth.c`):**
- Si `pam_authenticate()` retorna `PAM_SUCCESS` (contraseña correcta)
- Pero `pam_acct_mgmt()` retorna `PAM_PERM_DENIED` (cuenta bloqueada)
- Entonces retorna código 30 (faillock activo)

**En la UI (`LockScreen.qml`):**
- Detecta código 30 y ejecuta `faillock --user <username>`
- Extrae el tiempo restante de bloqueo (en segundos)
- Muestra countdown en tiempo real: "Cuenta bloqueada por intentos fallidos (2m 30s restantes)"
- El countdown se actualiza cada segundo automáticamente
- Al llegar a 0, el mensaje de error desaparece

**Ventajas:**
- El usuario sabe exactamente cuánto tiempo debe esperar
- No confunde "contraseña incorrecta" con "bloqueado por faillock"
- Feedback claro y profesional
