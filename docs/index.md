---
title: Mushy Terrain Generator
next: 
    url: /rules
---

The mushy terrain generator's goal is to make an easy to write format for multi-dimensional and multi-pass terrain generation. The format is easy to write and modify and flexible in use. The background image was generated with the following config:

```yaml
steps:
- height*moisture:
  # Base terrain
  - 1@2:rock,1:snow
  - 1@2:grass,3:plants
  - 2@1:sand,2:dirt,2:grass,3:plants
  - 1@2:sand,1:dirt,1:grass,1:plants,2:=water
  - 3@1:=water
  - tile*population:
    # Adding cities
    - sand@9:-,1:buildings
    - grass@2:-,1:buildings
    - dirt,plants@3:-,1:buildings
```

You can view the source code on [GitHub](https://github.com/GammaGames/mushy-terrain/blob/master/assets/scripts/tilegen.gd) and you can download a playable demo for Windows, Linux, or macOS [here](/download).
