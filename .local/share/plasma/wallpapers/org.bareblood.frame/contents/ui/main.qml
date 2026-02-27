/*
    SPDX-FileCopyrightText: 2013 Marco Martin <mart@kde.org>
    SPDX-FileCopyrightText: 2014 Sebastian Kügler <sebas@kde.org>
    SPDX-FileCopyrightText: 2014 Kai Uwe Broulik <kde@privat.broulik.de>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.wallpapers.image as Wallpaper
import org.kde.plasma.plasmoid

WallpaperItem {
    id: root

    // used by WallpaperInterface for drag and drop
    onOpenUrlRequested: (url) => {
        if (root.pluginName === "org.kde.image") {
            const result = imageWallpaper.addUsersWallpaper(url);
            if (result.length > 0) {
                // Can be a file or a folder (KPackage)
                root.configuration.Image = result;
            }
        } else {
            imageWallpaper.addSlidePath(url);
            // Save drag and drop result
            root.configuration.SlidePaths = imageWallpaper.slidePaths;
        }
        root.configuration.writeConfig();
    }

    contextualActions: root.pluginName === "org.bareblood.frame" ? [openWallpaperAction, imageWallpaper.nextSlideAction] : []

    PlasmaCore.Action {
        id: openWallpaperAction
        text: i18nd("plasma_wallpaper_org.kde.image", "Open Wallpaper Image")
        icon.name: "document-open"
        onTriggered: imageView.mediaProxy.openModelImage();
    }

    Connections {
		enabled: root.pluginName === "org.bareblood.frame"
        target: Qt.application
        function onAboutToQuit() {
            root.configuration.writeConfig(); // Save the last position
        }
    }

    Component.onCompleted: {
        // In case plasmashell crashes when the config dialog is opened
        root.configuration.PreviewImage = "null";
        root.loading = true; // delays ksplash until the wallpaper has been loaded
    }

    ImageStackView {
        id: imageView
        anchors.fill: parent

        fillMode: root.configuration.FillMode
        configColor: root.configuration.Color
        blur: root.configuration.Blur
        source: {
            if (root.pluginName === "org.bareblood.frame") {
                return imageWallpaper.image;
            }
            if (root.configuration.PreviewImage !== "null") {
                return root.configuration.PreviewImage;
            }
            return root.configuration.Image;
        }
        sourceSize: Qt.size(root.width * Screen.devicePixelRatio, root.height * Screen.devicePixelRatio)
        wallpaperInterface: root

        Wallpaper.ImageBackend {
            id: imageWallpaper

            // Not using root.configuration.Image to avoid binding loop warnings
            configMap: root.configuration
            usedInConfig: false
            //the oneliner of difference between image and slideshow wallpapers
            renderingMode: (root.pluginName === "org.kde.image") ? Wallpaper.ImageBackend.SingleImage : Wallpaper.ImageBackend.SlideShow
            targetSize: imageView.sourceSize
            slidePaths: root.configuration.SlidePaths
            slideTimer: root.configuration.SlideInterval
            slideshowMode: root.configuration.SlideshowMode
            slideshowFoldersFirst: root.configuration.SlideshowFoldersFirst
            uncheckedSlides: root.configuration.UncheckedSlides

            // Invoked from C++
            function writeImageConfig(newImage: string) {
                configMap.Image = newImage;
            }
        }
    }

    Image {
        id: frameOverlay
        anchors.fill: parent
        source: Qt.resolvedUrl("../frame.png")
        fillMode: Image.Stretch
        smooth: true
        z: 999
    }

    Component.onDestruction: {
        if (root.pluginName === "org.bareblood.frame") {
            root.configuration.writeConfig(); // Save the last position
        }
    }
}
