---
title: Download
previous: 
    url: /
next: 
    url: /parser
---

* The project can have only one scene
* The one scene can consist of at most 10 nodes
  * You can duplicate nodes using code at runtime
  * You cannot create new nodes using code at runtime
* The one scene can have at most 10 scripts
  * Extended scripts count as a single script with one more for each extension
  * Autoload scripts count as a single node
  * Scripts do not have to be attached to nodes
  * Shaders do not count against scripts
* Each node may have a script, but each script can have no more than 100 lines
  * This includes comments and whitespace
  * Length is to encourage documentation
* The total project size can be no larger than 1MB in size
  * This allows users to include textures, sounds, 3D models, etc

View [changelog](https://github.com/GammaGames/godot-10pow/commits/master/docs/rules.md).
