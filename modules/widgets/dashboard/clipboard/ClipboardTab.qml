import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import qs.modules.theme
import qs.modules.components
import qs.modules.globals
import qs.modules.services
import qs.config

Item {
    id: root
    focus: true

    Keys.onEscapePressed: {
        if (root.deleteMode) {
            console.log("DEBUG: Escape pressed in delete mode - canceling");
            root.cancelDeleteMode();
        } else {
            // Cerrar el dashboard
            Visibilities.setActiveModule("");
        }
    }

    property string searchText: ""
    property bool showResults: searchText.length > 0
    property int selectedIndex: -1
    property var allItems: []
    property bool hasNavigatedFromSearch: false
    property bool clearButtonFocused: false
    property bool clearButtonConfirmState: false

    // Delete mode state
    property bool deleteMode: false
    property string itemToDelete: ""
    property int originalSelectedIndex: -1
    property int deleteButtonIndex: 0

    // Options menu state
    property bool optionsMenuOpen: false
    property int menuItemIndex: -1
    property bool menuJustClosed: false

    property int previewImageSize: 200
    property string currentFullContent: ""

    implicitWidth: 400
    implicitHeight: 7 * 48 + 56

    onSelectedIndexChanged: {
        if (selectedIndex === -1 && resultsList.count > 0) {
            resultsList.positionViewAtIndex(0, ListView.Beginning);
        }
    }

    onSearchTextChanged: {
        updateFilteredItems();
    }

    function clearSearch() {
        searchText = "";
        selectedIndex = -1;
        hasNavigatedFromSearch = false;
        clearButtonFocused = false;
        clearButtonConfirmState = false;
        searchInput.focusInput();
        updateFilteredItems();
    }

    function resetClearButton() {
        clearButtonConfirmState = false;
    }

    function cancelDeleteModeFromExternal() {
        if (deleteMode) {
            console.log("DEBUG: Canceling delete mode from external source (tab change)");
            cancelDeleteMode();
        }
    }

    function enterDeleteMode(itemId) {
        console.log("DEBUG: Entering delete mode for item:", itemId);
        originalSelectedIndex = selectedIndex;
        deleteMode = true;
        itemToDelete = itemId;
        deleteButtonIndex = 0;
        root.forceActiveFocus();
    }

    function cancelDeleteMode() {
        console.log("DEBUG: Canceling delete mode");
        deleteMode = false;
        itemToDelete = "";
        deleteButtonIndex = 0;
        searchInput.focusInput();
        updateFilteredItems();
        selectedIndex = originalSelectedIndex;
        resultsList.currentIndex = originalSelectedIndex;
        originalSelectedIndex = -1;
    }

    function confirmDeleteItem() {
        console.log("DEBUG: Confirming delete for item:", itemToDelete);
        ClipboardService.deleteItem(itemToDelete);

        deleteMode = false;
        itemToDelete = "";
        deleteButtonIndex = 0;
        originalSelectedIndex = -1;
        selectedIndex = -1;
        hasNavigatedFromSearch = false;

        refreshClipboardHistory();
        searchInput.focusInput();
    }

    function clearClipboardHistory() {
        ClipboardService.clear();
        clearButtonConfirmState = false;
        clearButtonFocused = false;
        searchInput.focusInput();
    }

    function focusSearchInput() {
        searchInput.focusInput();
    }

    function updateFilteredItems() {
        var newItems = [];

        for (var i = 0; i < ClipboardService.items.length; i++) {
            var item = ClipboardService.items[i];
            var content = item.preview || "";

            if (searchText.length === 0 || content.toLowerCase().includes(searchText.toLowerCase())) {
                newItems.push(item);
            }
        }

        allItems = newItems;

        if (searchText.length > 0 && allItems.length > 0) {
            selectedIndex = 0;
            resultsList.currentIndex = 0;
        } else if (searchText.length === 0) {
            selectedIndex = -1;
            resultsList.currentIndex = -1;
        }
    }

    function onDownPressed() {
        if (!root.hasNavigatedFromSearch) {
            root.hasNavigatedFromSearch = true;
            if (resultsList.count > 0) {
                if (root.selectedIndex === -1) {
                    root.selectedIndex = 0;
                    resultsList.currentIndex = 0;
                }
            }
        } else {
            if (resultsList.count > 0 && root.selectedIndex >= 0) {
                if (root.selectedIndex < resultsList.count - 1) {
                    root.selectedIndex++;
                    resultsList.currentIndex = root.selectedIndex;
                }
            }
        }
    }

    function onUpPressed() {
        if (root.selectedIndex > 0) {
            root.selectedIndex--;
            resultsList.currentIndex = root.selectedIndex;
        } else if (root.selectedIndex === 0) {
            root.selectedIndex = -1;
            root.hasNavigatedFromSearch = false;
            resultsList.currentIndex = -1;
        }
    }

    function refreshClipboardHistory() {
        ClipboardService.list();
    }

    function copyToClipboard(itemId) {
        // Find the item to determine if it's an image
        for (var i = 0; i < root.allItems.length; i++) {
            if (root.allItems[i].id === itemId) {
                var item = root.allItems[i];
                if (item.isImage && item.binaryPath) {
                    copyProcess.command = ["sh", "-c", "cat '" + item.binaryPath + "' | wl-copy"];
                } else {
                    copyProcess.command = ["sh", "-c",
                                          "sqlite3 '" + ClipboardService.dbPath + "' \"SELECT full_content FROM clipboard_items WHERE id = " + itemId + ";\" | wl-copy"];
                }
                copyProcess.running = true;
                break;
            }
        }
    }

    // MouseArea global para detectar clicks en cualquier espacio vacío
    MouseArea {
        anchors.fill: parent
        enabled: root.deleteMode
        z: -10

        onClicked: {
            if (root.deleteMode) {
                console.log("DEBUG: Clicked on empty space globally - canceling delete mode");
                root.cancelDeleteMode();
            }
        }
    }

    // Conexiones al servicio
    Connections {
        target: ClipboardService
        function onListCompleted() {
            updateFilteredItems();
        }
    }

    // Conexión para cargar imágenes cuando cambia la selección
    Connections {
        target: root
        function onSelectedIndexChanged() {
            if (root.selectedIndex >= 0 && root.selectedIndex < root.allItems.length) {
                let item = root.allItems[root.selectedIndex];
                if (item.isImage && !ClipboardService.getImageData(item.id)) {
                    ClipboardService.decodeToDataUrl(item.id, item.mime);
                } else if (!item.isImage) {
                    // Obtener contenido completo para texto
                    root.currentFullContent = "";
                    ClipboardService.getFullContent(item.id);
                }
            }
        }
    }

    // Conexión para recibir el contenido completo
    Connections {
        target: ClipboardService
        function onFullContentRetrieved(itemId, content) {
            if (root.selectedIndex >= 0 && root.selectedIndex < root.allItems.length) {
                let item = root.allItems[root.selectedIndex];
                if (item.id === itemId) {
                    root.currentFullContent = content;
                }
            }
        }
    }

    // Proceso para copiar al portapapeles
    Process {
        id: copyProcess
        running: false

        onExited: function (code) {
        // No cerrar el dashboard después de copiar
        // if (code === 0) {
        //     root.itemSelected();
        // }
        }
    }

    Row {
        id: mainLayout
        anchors.fill: parent
        spacing: 8

        // Columna izquierda: Search + Lista
        Column {
            width: parent.width * 0.35
            height: parent.height
            spacing: 10

            // Barra de búsqueda con botón de limpiar
            Row {
                width: parent.width
                height: 48
                spacing: 8

                SearchInput {
                    id: searchInput
                    width: parent.width - clearButton.width - parent.spacing
                    height: parent.height
                    text: root.searchText
                    placeholderText: "Search clipboard history..."

                    onSearchTextChanged: text => {
                        root.searchText = text;
                    }

                    onAccepted: {
                        if (root.deleteMode) {
                            console.log("DEBUG: Enter in delete mode - canceling");
                            root.cancelDeleteMode();
                        } else {
                            if (root.selectedIndex >= 0 && root.selectedIndex < root.allItems.length) {
                                let selectedItem = root.allItems[root.selectedIndex];
                                console.log("DEBUG: Selected item:", selectedItem);
                                if (selectedItem && !root.deleteMode) {
                                    root.copyToClipboard(selectedItem.id);
                                    Visibilities.setActiveModule("");
                                }
                            } else {
                                console.log("DEBUG: No action taken - selectedIndex:", root.selectedIndex, "count:", root.allItems.length);
                            }
                        }
                    }

                    onShiftAccepted: {
                        if (!root.deleteMode) {
                            if (root.selectedIndex >= 0 && root.selectedIndex < root.allItems.length) {
                                let selectedItem = root.allItems[root.selectedIndex];
                                console.log("DEBUG: Selected item for deletion:", selectedItem);
                                if (selectedItem) {
                                    root.enterDeleteMode(selectedItem.id);
                                }
                            }
                        }
                    }

                    onEscapePressed: {
                        if (!root.deleteMode) {
                            Visibilities.setActiveModule("");
                        }
                    }

                    onDownPressed: {
                        root.onDownPressed();
                    }

                    onUpPressed: {
                        root.onUpPressed();
                    }
                }

                // Botón de limpiar historial
                Rectangle {
                    id: clearButton
                    width: root.clearButtonConfirmState ? 120 : 48
                    height: 48
                    radius: searchInput.radius
                    color: {
                        if (root.clearButtonConfirmState) {
                            return Colors.error;
                        } else if (root.clearButtonFocused || clearButtonMouseArea.containsMouse) {
                            return Colors.surfaceBright;
                        } else {
                            return Colors.surface;
                        }
                    }
                    focus: root.clearButtonFocused
                    activeFocusOnTab: true

                    Behavior on color {
                        enabled: Config.animDuration > 0
                        ColorAnimation {
                            duration: Config.animDuration / 2
                            easing.type: Easing.OutQuart
                        }
                    }

                    Behavior on width {
                        enabled: Config.animDuration > 0
                        NumberAnimation {
                            duration: Config.animDuration
                            easing.type: Easing.OutQuart
                        }
                    }

                    onActiveFocusChanged: {
                        if (activeFocus) {
                            root.clearButtonFocused = true;
                        } else {
                            root.clearButtonFocused = false;
                            root.resetClearButton();
                        }
                    }

                    MouseArea {
                        id: clearButtonMouseArea
                        anchors.fill: parent
                        hoverEnabled: true

                        onClicked: {
                            if (root.clearButtonConfirmState) {
                                root.clearClipboardHistory();
                            } else {
                                root.clearButtonConfirmState = true;
                            }
                        }
                    }

                    Row {
                        id: clearButtonContent
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 8

                        Text {
                            width: 32
                            height: parent.height
                            text: root.clearButtonConfirmState ? Icons.alert : Icons.trash
                            textFormat: Text.RichText
                            font.family: Icons.font
                            font.pixelSize: 20
                            color: root.clearButtonConfirmState ? Colors.overError : Colors.primary
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter

                            Behavior on color {
                                enabled: Config.animDuration > 0
                                ColorAnimation {
                                    duration: Config.animDuration / 2
                                    easing.type: Easing.OutQuart
                                }
                            }
                        }

                        Text {
                            width: parent.width - 32 - parent.spacing
                            height: parent.height
                            text: "Clear all?"
                            font.family: Config.theme.font
                            font.weight: Font.Bold
                            font.pixelSize: Config.theme.fontSize
                            color: Colors.overError
                            opacity: root.clearButtonConfirmState ? 1.0 : 0.0
                            visible: opacity > 0
                            verticalAlignment: Text.AlignVCenter

                            Behavior on opacity {
                                enabled: Config.animDuration > 0
                                NumberAnimation {
                                    duration: Config.animDuration / 2
                                    easing.type: Easing.OutQuart
                                }
                            }
                        }
                    }

                    Keys.onPressed: event => {
                        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                            if (root.clearButtonConfirmState) {
                                root.clearClipboardHistory();
                            } else {
                                root.clearButtonConfirmState = true;
                            }
                            event.accepted = true;
                        } else if (event.key === Qt.Key_Escape) {
                            root.resetClearButton();
                            root.clearButtonFocused = false;
                            searchInput.focusInput();
                            event.accepted = true;
                        } else if (event.key === Qt.Key_Tab && (event.modifiers & Qt.ShiftModifier)) {
                            root.resetClearButton();
                            root.clearButtonFocused = false;
                            searchInput.focusInput();
                            event.accepted = true;
                        }
                    }
                }
            }

            // Lista del clipboard
            Item {
                width: parent.width
                height: parent.height - 58

                ListView {
                    id: resultsList
                    anchors.fill: parent
                    visible: ClipboardService.items.length > 0
                    clip: true
                    interactive: !root.deleteMode
                    cacheBuffer: 96
                    reuseItems: false
                    boundsBehavior: Flickable.StopAtBounds

                    model: root.allItems
                    currentIndex: root.selectedIndex

                    onCurrentIndexChanged: {
                        if (currentIndex !== root.selectedIndex) {
                            root.selectedIndex = currentIndex;
                        }
                    }

                    delegate: Rectangle {
                        required property var modelData
                        required property int index

                        width: resultsList.width
                        height: 48
                        color: "transparent"
                        radius: 16

                        property bool isInDeleteMode: root.deleteMode && modelData.id === root.itemToDelete
                        property bool isSelected: root.selectedIndex === index
                        property string displayText: {
                            if (isInDeleteMode) {
                                let preview = modelData.preview || "";
                                // Replace newlines with spaces for single-line display
                                preview = preview.replace(/\n/g, ' ').replace(/\r/g, '');
                                return "Delete \"" + preview.substring(0, 20) + (preview.length > 20 ? '...' : '') + "\"?";
                            } else if (modelData.isImage) {
                                return "Image";
                            } else {
                                let preview = modelData.preview || "";
                                // Replace newlines with spaces for single-line display
                                return preview.replace(/\n/g, ' ').replace(/\r/g, '');
                            }
                        }

                        MouseArea {
                            id: mouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            enabled: !root.deleteMode && !root.optionsMenuOpen
                            acceptedButtons: Qt.LeftButton | Qt.RightButton

                            property real startX: 0
                            property real startY: 0
                            property bool isDragging: false
                            property bool longPressTriggered: false

                            onEntered: {
                                if (!root.deleteMode && !root.optionsMenuOpen) {
                                    root.selectedIndex = index;
                                    resultsList.currentIndex = index;
                                }
                            }

                            onClicked: mouse => {
                                if (menuJustClosed) {
                                    return;
                                }

                                if (mouse.button === Qt.LeftButton && !isInDeleteMode) {
                                    if (root.deleteMode && modelData.id !== root.itemToDelete) {
                                        console.log("DEBUG: Clicking item outside delete mode - canceling");
                                        root.cancelDeleteMode();
                                        return;
                                    }

                                    if (!root.deleteMode) {
                                        root.copyToClipboard(modelData.id);
                                        Visibilities.setActiveModule("");
                                    }
                                } else if (mouse.button === Qt.RightButton) {
                                    if (root.deleteMode) {
                                        console.log("DEBUG: Right click while in delete mode - canceling");
                                        root.cancelDeleteMode();
                                        return;
                                    }

                                    console.log("DEBUG: Right click detected, showing context menu");
                                    root.menuItemIndex = index;
                                    root.optionsMenuOpen = true;
                                    contextMenu.popup(mouse.x, mouse.y);
                                }
                            }

                            onPressed: mouse => {
                                startX = mouse.x;
                                startY = mouse.y;
                                isDragging = false;
                                longPressTriggered = false;

                                if (mouse.button !== Qt.RightButton) {
                                    longPressTimer.start();
                                }
                            }

                            onPositionChanged: mouse => {
                                if (pressed && mouse.button !== Qt.RightButton) {
                                    let deltaX = mouse.x - startX;
                                    let deltaY = mouse.y - startY;
                                    let distance = Math.sqrt(deltaX * deltaX + deltaY * deltaY);

                                    if (distance > 10) {
                                        isDragging = true;
                                        longPressTimer.stop();

                                        if (deltaX < -50 && Math.abs(deltaY) < 30) {
                                            if (!longPressTriggered) {
                                                root.enterDeleteMode(modelData.id);
                                                longPressTriggered = true;
                                            }
                                        }
                                    }
                                }
                            }

                            // Botones de acción que aparecen desde la derecha
                            Rectangle {
                                id: actionContainer
                                anchors.right: parent.right
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.rightMargin: 8
                                width: 68
                                height: 32
                                color: "transparent"
                                opacity: isInDeleteMode ? 1.0 : 0.0
                                visible: opacity > 0

                                transform: Translate {
                                    x: isInDeleteMode ? 0 : 80

                                    Behavior on x {
                                        enabled: Config.animDuration > 0
                                        NumberAnimation {
                                            duration: Config.animDuration
                                            easing.type: Easing.OutQuart
                                        }
                                    }
                                }

                                Behavior on opacity {
                                    enabled: Config.animDuration > 0
                                    NumberAnimation {
                                        duration: Config.animDuration / 2
                                        easing.type: Easing.OutQuart
                                    }
                                }

                                Rectangle {
                                    id: deleteHighlight
                                    color: Colors.overError
                                    radius: Config.roundness > 0 ? Math.max(Config.roundness - 4, 0) : 0
                                    visible: isInDeleteMode
                                    z: 0

                                    property real activeButtonMargin: 2
                                    property real idx1X: root.deleteButtonIndex
                                    property real idx2X: root.deleteButtonIndex

                                    x: {
                                        let minX = Math.min(idx1X, idx2X) * 36 + activeButtonMargin;
                                        return minX;
                                    }

                                    y: activeButtonMargin

                                    width: {
                                        let stretchX = Math.abs(idx1X - idx2X) * 36 + 32 - activeButtonMargin * 2;
                                        return stretchX;
                                    }

                                    height: 32 - activeButtonMargin * 2

                                    Behavior on idx1X {
                                        enabled: Config.animDuration > 0
                                        NumberAnimation {
                                            duration: Config.animDuration / 3
                                            easing.type: Easing.OutSine
                                        }
                                    }
                                    Behavior on idx2X {
                                        enabled: Config.animDuration > 0
                                        NumberAnimation {
                                            duration: Config.animDuration
                                            easing.type: Easing.OutSine
                                        }
                                    }
                                }

                                Row {
                                    id: actionButtons
                                    anchors.fill: parent
                                    spacing: 4

                                    Rectangle {
                                        id: cancelButton
                                        width: 32
                                        height: 32
                                        color: "transparent"
                                        radius: 6
                                        border.width: 0
                                        border.color: Colors.outline
                                        z: 1

                                        property bool isHighlighted: root.deleteButtonIndex === 0

                                        MouseArea {
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            onClicked: root.cancelDeleteMode()
                                            onEntered: {
                                                root.deleteButtonIndex = 0;
                                            }
                                            onExited: parent.color = "transparent"
                                        }

                                        Text {
                                            anchors.centerIn: parent
                                            text: Icons.cancel
                                            color: cancelButton.isHighlighted ? Colors.error : Colors.overError
                                            font.pixelSize: 14
                                            font.family: Icons.font
                                            textFormat: Text.RichText

                                            Behavior on color {
                                                enabled: Config.animDuration > 0
                                                ColorAnimation {
                                                    duration: Config.animDuration / 2
                                                    easing.type: Easing.OutQuart
                                                }
                                            }
                                        }
                                    }

                                    Rectangle {
                                        id: confirmButton
                                        width: 32
                                        height: 32
                                        color: "transparent"
                                        radius: 6
                                        z: 1

                                        property bool isHighlighted: root.deleteButtonIndex === 1

                                        MouseArea {
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            onClicked: root.confirmDeleteItem()
                                            onEntered: {
                                                root.deleteButtonIndex = 1;
                                            }
                                            onExited: parent.color = "transparent"
                                        }

                                        Text {
                                            anchors.centerIn: parent
                                            text: Icons.accept
                                            color: confirmButton.isHighlighted ? Colors.error : Colors.overError
                                            font.pixelSize: 14
                                            font.family: Icons.font
                                            textFormat: Text.RichText

                                            Behavior on color {
                                                enabled: Config.animDuration > 0
                                                ColorAnimation {
                                                    duration: Config.animDuration / 2
                                                    easing.type: Easing.OutQuart
                                                }
                                            }
                                        }
                                    }
                                }
                            }

                            onReleased: mouse => {
                                longPressTimer.stop();
                                isDragging = false;
                                longPressTriggered = false;
                            }

                            Timer {
                                id: longPressTimer
                                interval: 800
                                repeat: false
                                onTriggered: {
                                    if (!mouseArea.isDragging) {
                                        root.copyToClipboard(modelData.id);
                                        Visibilities.setActiveModule("");
                                        mouseArea.longPressTriggered = true;
                                    }
                                }
                            }
                        }

                        OptionsMenu {
                            id: contextMenu

                            onAboutToHide: {
                                mouseArea.enabled = false;
                            }

                            onClosed: {
                                root.optionsMenuOpen = false;
                                root.menuItemIndex = -1;
                                Qt.callLater(() => {
                                    mouseArea.enabled = !root.deleteMode && !root.optionsMenuOpen;
                                });
                                root.menuJustClosed = true;
                                menuClosedTimer.start();
                            }

                            Timer {
                                id: menuClosedTimer
                                interval: 100
                                repeat: false
                                onTriggered: {
                                    root.menuJustClosed = false;
                                }
                            }

                            items: [
                                {
                                    text: "Copy",
                                    icon: Icons.copy,
                                    highlightColor: Colors.primary,
                                    textColor: Colors.overPrimary,
                                    onTriggered: function () {
                                        console.log("DEBUG: Copy clicked from ContextMenu");
                                        root.copyToClipboard(modelData.id);
                                        Visibilities.setActiveModule("");
                                    }
                                },
                                {
                                    text: "Delete",
                                    icon: Icons.trash,
                                    highlightColor: Colors.overError,
                                    textColor: Colors.error,
                                    onTriggered: function () {
                                        console.log("DEBUG: Delete clicked from ContextMenu");
                                        root.enterDeleteMode(modelData.id);
                                    }
                                }
                            ]
                        }

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 8
                            anchors.rightMargin: isInDeleteMode ? 84 : 8
                            spacing: 8

                            Behavior on anchors.rightMargin {
                                enabled: Config.animDuration > 0
                                NumberAnimation {
                                    duration: Config.animDuration
                                    easing.type: Easing.OutQuart
                                }
                            }

                            Rectangle {
                                Layout.preferredWidth: 32
                                Layout.preferredHeight: 32
                                color: {
                                    if (isInDeleteMode) {
                                        return Colors.overError;
                                    } else if (isSelected) {
                                        return Colors.overPrimary;
                                    } else {
                                        return Colors.surface;
                                    }
                                }
                                radius: Config.roundness > 0 ? Math.max(Config.roundness - 4, 0) : 0

                                Behavior on color {
                                    enabled: Config.animDuration > 0
                                    ColorAnimation {
                                        duration: Config.animDuration / 2
                                        easing.type: Easing.OutQuart
                                    }
                                }

                                Text {
                                    anchors.centerIn: parent
                                    text: isInDeleteMode ? Icons.trash : (modelData.isImage ? Icons.image : Icons.clip)
                                    color: {
                                        if (isInDeleteMode) {
                                            return Colors.error;
                                        } else if (isSelected) {
                                            return Colors.primary;
                                        } else {
                                            return Colors.overBackground;
                                        }
                                    }
                                    font.family: Icons.font
                                    font.pixelSize: 16
                                    textFormat: Text.RichText

                                    Behavior on color {
                                        enabled: Config.animDuration > 0
                                        ColorAnimation {
                                            duration: Config.animDuration / 2
                                            easing.type: Easing.OutQuart
                                        }
                                    }
                                }
                            }

                            Text {
                                Layout.fillWidth: true
                                text: displayText
                                color: {
                                    if (isInDeleteMode) {
                                        return Colors.overError;
                                    } else if (isSelected) {
                                        return Colors.overPrimary;
                                    } else {
                                        return Colors.overBackground;
                                    }
                                }
                                font.family: Config.theme.font
                                font.pixelSize: Config.theme.fontSize
                                font.weight: Font.Bold
                                elide: Text.ElideRight
                                maximumLineCount: 1
                                wrapMode: Text.NoWrap

                                Behavior on color {
                                    enabled: Config.animDuration > 0
                                    ColorAnimation {
                                        duration: Config.animDuration / 2
                                        easing.type: Easing.OutQuart
                                    }
                                }
                            }
                        }
                    }

                    highlight: Rectangle {
                        color: root.deleteMode ? Colors.error : Colors.primary
                        radius: Config.roundness > 0 ? Config.roundness + 4 : 0
                        visible: root.selectedIndex >= 0 && (root.optionsMenuOpen ? root.selectedIndex === root.menuItemIndex : true)

                        Behavior on color {
                            enabled: Config.animDuration > 0
                            ColorAnimation {
                                duration: Config.animDuration / 2
                                easing.type: Easing.OutQuart
                            }
                        }
                    }

                    highlightMoveDuration: Config.animDuration > 0 ? Config.animDuration / 2 : 0
                    highlightMoveVelocity: -1
                }

                MouseArea {
                    anchors.fill: resultsList
                    enabled: root.deleteMode
                    z: -1

                    onClicked: {
                        if (root.deleteMode) {
                            console.log("DEBUG: Clicked on empty space in list - canceling delete mode");
                            root.cancelDeleteMode();
                        }
                    }
                }

                Column {
                    anchors.centerIn: parent
                    spacing: 16
                    visible: ClipboardService.items.length === 0

                    Text {
                        text: Icons.clipboard
                        font.family: Icons.font
                        font.pixelSize: 48
                        color: Colors.surfaceBright
                        anchors.horizontalCenter: parent.horizontalCenter
                        textFormat: Text.RichText
                    }

                    Text {
                        text: "No clipboard history"
                        font.family: Config.theme.font
                        font.pixelSize: Config.theme.fontSize + 2
                        font.weight: Font.Bold
                        color: Colors.overBackground
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    Text {
                        text: "Copy something to get started"
                        font.family: Config.theme.font
                        font.pixelSize: Config.theme.fontSize
                        color: Colors.surfaceBright
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }
            }
        }

        // Separator
        Rectangle {
            width: 2
            height: parent.height
            radius: Config.roundness
            color: Colors.surface
        }

        // Preview panel (toda la altura, resto del ancho)
        Item {
            id: previewPanel
            width: parent.width - parent.spacing * 2 - 2 - (parent.width * 0.35)
            height: parent.height
            visible: ClipboardService.items.length > 0

            property var currentItem: root.selectedIndex >= 0 && root.selectedIndex < root.allItems.length ? root.allItems[root.selectedIndex] : null

            Item {
                anchors.fill: parent
                anchors.margins: 8

                // Preview para imagen
                Image {
                    id: previewImage
                    anchors.fill: parent
                    fillMode: Image.PreserveAspectFit
                    visible: previewPanel.currentItem && previewPanel.currentItem.isImage
                    source: {
                        if (previewPanel.currentItem && previewPanel.currentItem.isImage) {
                            ClipboardService.revision;
                            return ClipboardService.getImageData(previewPanel.currentItem.id);
                        }
                        return "";
                    }
                    clip: true
                    cache: false
                    asynchronous: true
                }

                // Placeholder cuando la imagen no está lista
                Rectangle {
                    anchors.centerIn: parent
                    width: 120
                    height: 120
                    color: Colors.surfaceBright
                    radius: Config.roundness > 0 ? Config.roundness + 4 : 0
                    visible: previewPanel.currentItem && previewPanel.currentItem.isImage && previewImage.status !== Image.Ready

                    Text {
                        anchors.centerIn: parent
                        text: Icons.image
                        textFormat: Text.RichText
                        font.family: Icons.font
                        font.pixelSize: 48
                        color: Colors.primary
                    }
                }

                // Preview para texto con scroll
                Flickable {
                    anchors.fill: parent
                    visible: previewPanel.currentItem && !previewPanel.currentItem.isImage
                    clip: true
                    contentWidth: width
                    contentHeight: previewText.height
                    boundsBehavior: Flickable.StopAtBounds

                    Text {
                        id: previewText
                        text: root.currentFullContent || (previewPanel.currentItem ? previewPanel.currentItem.preview : "")
                        font.family: Config.theme.font
                        font.pixelSize: Config.theme.fontSize
                        color: Colors.overBackground
                        wrapMode: Text.Wrap
                        width: parent.width
                        textFormat: Text.PlainText
                    }

                    ScrollBar.vertical: ScrollBar {
                        policy: ScrollBar.AsNeeded
                    }
                }

                // Placeholder cuando no hay nada seleccionado
                Column {
                    anchors.centerIn: parent
                    spacing: 16
                    visible: !previewPanel.currentItem

                    Text {
                        text: Icons.clipboard
                        font.family: Icons.font
                        font.pixelSize: 48
                        color: Colors.surfaceBright
                        anchors.horizontalCenter: parent.horizontalCenter
                        textFormat: Text.RichText
                    }
                }
            }
        }
    }

    // Handler de teclas global para manejar navegación en modo eliminar
    Keys.onPressed: event => {
        if (root.deleteMode) {
            if (event.key === Qt.Key_Left) {
                root.deleteButtonIndex = 0;
                event.accepted = true;
            } else if (event.key === Qt.Key_Right) {
                root.deleteButtonIndex = 1;
                event.accepted = true;
            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Space) {
                if (root.deleteButtonIndex === 0) {
                    console.log("DEBUG: Enter/Space pressed - canceling delete");
                    root.cancelDeleteMode();
                } else {
                    console.log("DEBUG: Enter/Space pressed - confirming delete");
                    root.confirmDeleteItem();
                }
                event.accepted = true;
            } else if (event.key === Qt.Key_Escape) {
                console.log("DEBUG: Escape pressed in delete mode - canceling without closing notch");
                root.cancelDeleteMode();
                event.accepted = true;
            }
        }
    }

    // Monitor cambios en deleteMode
    onDeleteModeChanged: {
        if (!deleteMode) {
            console.log("DEBUG: Delete mode ended");
        }
    }

    Component.onCompleted: {
        refreshClipboardHistory();
        Qt.callLater(() => {
            focusSearchInput();
        });
    }
}
