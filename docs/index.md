---
title: Procedural Generation Ruleset
---

> **NEW!** Try it [in the browser]({{ site.url }}/play/)!

The goal of PGR is to make an easy to write format for multi-pass-ish procedural terrain generation. The format is flexible enough that it could be used for other generation as well. The background image was generated with the following config:

```yaml
steps:
- height*moisture:
  # Base terrain
  - "1@2:rock,1:snow"
  - "1@2:grass,3:plants"
  - "2@1:sand,2:dirt,2:grass,3:plants"
  - "1@2:sand,1:dirt,1:grass,1:plants,2:=water"
  - "3@1:=water"
  - tile*population:
    # Adding cities
    - "sand@9:-,1:buildings"
    - "grass@2:-,1:buildings"
    - "dirt,plants@3:-,1:buildings"
```

A full writeup on the format can be found on [my personal blog](https://www.gammagames.net/posts/programming/procgen-ruleset) or [Medium](https://medium.com/@gammagames/procedural-generation-ruleset-478a7aeb4c12), the source code is available on [GitHub](https://github.com/GammaGames/procedural-generation-ruleset/blob/master/assets/scripts/tilegen.gd), and you can download a playable demo for Windows, Linux, or macOS [here](download).
