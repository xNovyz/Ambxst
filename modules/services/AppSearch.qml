pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property var substitutions: ({
        "code-url-handler": "visual-studio-code",
        "Code": "visual-studio-code",
        "gnome-tweaks": "org.gnome.tweaks",
        "pavucontrol-qt": "pavucontrol",
        "wps": "wps-office2019-kprometheus",
        "wpsoffice": "wps-office2019-kprometheus",
        "footclient": "foot",
        "zen": "zen-browser",
    })
    property list<var> regexSubstitutions: [
        {
            "regex": /^steam_app_(\d+)$/,
            "replace": "steam_icon_$1"
        },
        {
            "regex": /Minecraft.*/,
            "replace": "minecraft"
        },
        {
            "regex": /.*polkit.*/,
            "replace": "system-lock-screen"
        },
        {
            "regex": /gcr.prompter/,
            "replace": "system-lock-screen"
        }
    ]

    function iconExists(iconName) {
        return (Quickshell.iconPath(iconName, true).length > 0) 
            && !iconName.includes("image-missing");
    }

    function getIconFromDesktopEntry(className) {
        if (!className || className.length === 0) return null;

        const normalizedClassName = className.toLowerCase();

        for (let i = 0; i < list.length; i++) {
            const app = list[i];
            // Match by executable name (first command argument)
            if (app.command && app.command.length > 0) {
                const executableLower = app.command[0].toLowerCase();
                if (executableLower === normalizedClassName) {
                    return app.icon || "application-x-executable";
                }
            }
            // Match by application name
            if (app.name && app.name.toLowerCase() === normalizedClassName) {
                return app.icon || "application-x-executable";
            }
            // Match by keywords
            if (app.keywords && app.keywords.length > 0) {
                for (let j = 0; j < app.keywords.length; j++) {
                    if (app.keywords[j].toLowerCase() === normalizedClassName) {
                        return app.icon || "application-x-executable";
                    }
                }
            }
        }
        return null;
    }

    function guessIcon(str) {
        if (!str || str.length == 0) return "image-missing";

        // First, try to find icon from desktop entries
        const desktopIcon = getIconFromDesktopEntry(str);
        if (desktopIcon) return desktopIcon;

        if (substitutions[str])
            return substitutions[str];

        for (let i = 0; i < regexSubstitutions.length; i++) {
            const substitution = regexSubstitutions[i];
            const replacedName = str.replace(
                substitution.regex,
                substitution.replace,
            );
            if (replacedName != str) return replacedName;
        }

        if (iconExists(str)) return str;

        const extensionGuess = str.split('.').pop().toLowerCase();
        if (iconExists(extensionGuess)) return extensionGuess;

        const dashedGuess = str.toLowerCase().replace(/\s+/g, "-");
        if (iconExists(dashedGuess)) return dashedGuess;

        return str;
    }
    
    readonly property list<DesktopEntry> list: Array.from(DesktopEntries.applications.values)
        .sort((a, b) => a.name.localeCompare(b.name))
    
    function getAllApps() {
        const results = [];
        
        for (let i = 0; i < list.length; i++) {
            const app = list[i];
            results.push({
                name: app.name,
                icon: app.icon || "application-x-executable",
                id: app.id,
                execString: app.execString,
                comment: app.comment || "",
                categories: app.categories || [],
                runInTerminal: app.runInTerminal || false,
                execute: () => {
                    app.execute();
                }
            });
        }
        
        return results; // Show all apps
    }
    
    function fuzzyQuery(search) {
        if (!search || search.length === 0) return [];
        
        const searchLower = search.toLowerCase();
        const results = [];
        
        for (let i = 0; i < list.length; i++) {
            const app = list[i];
            let score = 0;
            let matchFound = false;
            
            // Search in name (highest priority)
            const nameLower = app.name.toLowerCase();
            if (nameLower === searchLower) {
                score += 100; // Exact name match
                matchFound = true;
            } else if (nameLower.startsWith(searchLower)) {
                score += 80; // Name starts with search
                matchFound = true;
            } else if (nameLower.includes(searchLower)) {
                score += 60; // Name contains search
                matchFound = true;
            }
            
            // Search in command (high priority)
            if (app.command && app.command.length > 0) {
                const commandStr = app.command.join(' ').toLowerCase();
                if (commandStr.includes(searchLower)) {
                    score += 40; // Command contains search
                    matchFound = true;
                }
                
                // También buscar en el primer elemento del comando (executable)
                const executableLower = app.command[0].toLowerCase();
                if (executableLower.includes(searchLower)) {
                    score += 50; // Executable name contains search
                    matchFound = true;
                }
            }
            
            // Search in comment/description (medium priority)
            if (app.comment) {
                const commentLower = app.comment.toLowerCase();
                if (commentLower.includes(searchLower)) {
                    score += 30; // Comment contains search
                    matchFound = true;
                }
            }
            
            // Search in genericName (medium priority)
            if (app.genericName) {
                const genericLower = app.genericName.toLowerCase();
                if (genericLower.includes(searchLower)) {
                    score += 25; // Generic name contains search
                    matchFound = true;
                }
            }
            
            // Search in keywords (medium priority)
            if (app.keywords && app.keywords.length > 0) {
                for (let j = 0; j < app.keywords.length; j++) {
                    if (app.keywords[j].toLowerCase().includes(searchLower)) {
                        score += 20; // Keyword contains search
                        matchFound = true;
                        break;
                    }
                }
            }
            
            if (matchFound) {
                results.push({
                    name: app.name,
                    icon: app.icon || "application-x-executable",
                    score: score,
                    id: app.id,
                    execString: app.execString,
                    comment: app.comment || "",
                    categories: app.categories || [],
                    runInTerminal: app.runInTerminal || false,
                    execute: () => {
                        app.execute();
                    }
                });
            }
        }
        
        // Sort by score (highest first), then by name
        results.sort((a, b) => {
            if (a.score !== b.score) {
                return b.score - a.score;
            }
            return a.name.localeCompare(b.name);
        });
        
        return results.slice(0, 10); // Limit results
    }
}
