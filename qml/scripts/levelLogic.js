
function createRandomRowForRowNumber(rowNumber) {
    for(var i=0; i<roostColumns; i++) {
        if(Math.random() < platformCreationProbability ) {

            var newRoostCenterPos = Qt.point(i*gridSize + gridSize/2, rowNumber*gridSize + gridSize/2);

            if(physicsWorld.bodyAt(newRoostCenterPos)) {
                console.debug("no Roost can be created because there is a window already");
                continue;
            }

            console.debug("creating a new Roost at position", i*gridSize + gridSize/2, ",", rowNumber*gridSize + gridSize/2);

            entityManager.createEntityFromUrlWithProperties(Qt.resolvedUrl("entities/Roost.qml"),
                                 {"x": newRoostCenterPos.x,
                                     "y": newRoostCenterPos.y
                                 });

            // create a coin in 30% of all created blocks
            if(Math.random() < coinCreationPropability) {

                // look at 1 grid position above
                var coinCenterPos = Qt.point(newRoostCenterPos.x, newRoostCenterPos.y-scene.gridSize);

                // test if one grid above is an empty field (so if no block is built there) - if so, a coin can be created
                if(physicsWorld.bodyAt(coinCenterPos)) {
                    console.debug("there is a block above the to create block, dont create a coin here!")
                    continue;
                }


                /*entityManager.createEntityFromUrlWithProperties*/
                entityManager.createEntityFromUrlWithProperties(Qt.resolvedUrl("entities/Coin.qml"),
                                     {"x": coinCenterPos.x,
                                         "y": coinCenterPos.y+0.7*scene.gridSize // move slightly up, so it looks better
                                     });
            }
        } else if(i < roostColumns-1 && Math.random() < windowCreationProbability ) {


            // the i<columns-1 check is required, because the window has a size of 2 grids, and its anchor is top left

            var newWindowTopleftPos = Qt.point(i*gridSize, rowNumber*gridSize);

            console.debug("newWindowTopleftPos.y-lastWindowY:", newWindowTopleftPos.y-lastWindowY)
            // this avoids creating too many windows, so not possible to have more than 2 on a scene with this code!
            if(newWindowTopleftPos.y-lastWindowY < minimumWindowHeightDifference) {
                console.debug("difference between last Window and current to create one too small!")
                continue;
            }

            // this might happen if a window was already created at this position
            if(physicsWorld.bodyAt(newWindowTopleftPos)) {
                console.debug("body at position x:", newWindowTopleftPos.x, ", y:", newWindowTopleftPos.y, physicsWorld.bodyAt(newWindowTopleftPos))
                console.debug("there is a window at the position where to create a window, so no creation is done");
                continue;
            }

            console.debug("creating a new Window... at position x:", newWindowTopleftPos.x, ", y:", newWindowTopleftPos.y, "lastWindowY:", lastWindowY);
            /*entityManager.createEntityFromUrlWithProperties*/
            entityManager.createEntityFromUrlWithProperties(Qt.resolvedUrl("entities/HenhouseWindow.qml"),
                                 {"x": newWindowTopleftPos.x,
                                     "y": newWindowTopleftPos.y,
                                     "z": 0 // put behind all others, except the background
                                 });

            lastWindowY = newWindowTopleftPos.y;
        }

    }
}
