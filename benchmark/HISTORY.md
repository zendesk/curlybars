# Benchmark history

Generated from the versions of `benchmark/results.json` in the git history (following only the first parent of merges) by `bundle exec rake benchmark` or `bundle exec rake benchmark:history`. Don't edit this file by hand. The latest results, and what each step measures, are in [RESULTS.md](RESULTS.md).

Each run is labeled with the commit it measured, or the git ref (e.g. a release tag) for runs of earlier versions. `*` marks runs with uncommitted changes.

## Runs

| Run | Date | Curlybars | Ruby | YJIT | ActionView | Machine |
|---|---|---|---|---|---|---|
| v1.16.1 | 2026-11-20 | 1.16.1 | 3.4.12 | disabled | 8.1.3.1 | Apple M1 Pro, Darwin 25.6.0 arm64 |
| v1.17.0 | 2026-11-20 | 1.17.0 | 3.4.12 | disabled | 8.1.3.1 | Apple M1 Pro, Darwin 25.6.0 arm64 |
| cf3dc41* | 2026-11-20 | 1.17.0 | 3.4.12 | disabled | 8.1.3.1 | Apple M1 Pro, Darwin 25.6.0 arm64 |
| bcbc92c* | 2026-11-20 | 1.17.0 | 3.4.12 | disabled | 8.1.3.1 | Apple M1 Pro, Darwin 25.6.0 arm64 |
| 29b002b* | 2026-11-20 | 1.17.0 | 3.4.12 | disabled | 8.1.3.1 | Apple M1 Pro, Darwin 25.6.0 arm64 |
| 5360a31* | 2026-11-20 | 1.17.0 | 3.4.12 | disabled | 8.1.3.1 | Apple M1 Pro, Darwin 25.6.0 arm64 |
| d4264c5* | 2026-11-20 | 1.17.0 | 3.4.12 | disabled | 8.1.3.1 | Apple M1 Pro, Darwin 25.6.0 arm64 |

## Allocations per call

Allocations don't depend on the machine, but can change with the Ruby and Rails versions (see "Runs").

### small

```mermaid
---
config:
  themeVariables:
    xyChart:
      plotColorPalette: "#0072B2, #E69F00, #009E73, #CC79A7"
---
xychart-beta
  title "small: allocations during Lex, Parse, Compile and Eval"
  x-axis ["v1.16.1", "v1.17.0", "cf3dc41*", "bcbc92c*", "29b002b*", "5360a31*", "d4264c5*"]
  y-axis "Objects" 0 --> 2400
  line "Lex" [981, 354, 354, 354, 354, 354, 354]
  line "Parse" [2132, 79, 79, 79, 79, 79, 79]
  line "Compile" [120, 107, 107, 107, 175, 175, 182]
  line "Eval" [322, 322, 322, 322, 196, 196, 81]
```

```mermaid
---
config:
  themeVariables:
    xyChart:
      plotColorPalette: "#D55E00"
---
xychart-beta
  title "small: allocations during Render"
  x-axis ["v1.16.1", "v1.17.0", "cf3dc41*", "bcbc92c*", "29b002b*", "5360a31*", "d4264c5*"]
  y-axis "Objects" 0 --> 400
  line "Render" [360, 320, 280, 280, 228, 228, 225]
```

| Run | Lex | Parse | Compile | Eval | Render | Render with ActionView |
|---|--:|--:|--:|--:|--:|--:|
| v1.16.1 | 981 | 2,132 | 120 | 322 | 360 | 419 |
| v1.17.0 | 354 | 79 | 107 | 322 | 320 | 379 |
| cf3dc41* | 354 | 79 | 107 | 322 | 280 | 339 |
| bcbc92c* | 354 | 79 | 107 | 322 | 280 | 339 |
| 29b002b* | 354 | 79 | 175 | 196 | 228 | 287 |
| 5360a31* | 354 | 79 | 175 | 196 | 228 | 287 |
| d4264c5* | 354 | 79 | 182 | 81 | 225 | 284 |

### medium

```mermaid
---
config:
  themeVariables:
    xyChart:
      plotColorPalette: "#0072B2, #E69F00, #009E73, #CC79A7"
---
xychart-beta
  title "medium: allocations during Lex, Parse, Compile and Eval"
  x-axis ["v1.16.1", "v1.17.0", "cf3dc41*", "bcbc92c*", "29b002b*", "5360a31*", "d4264c5*"]
  y-axis "Objects" 0 --> 5000
  line "Lex" [2175, 774, 774, 774, 774, 774, 774]
  line "Parse" [4513, 157, 157, 157, 157, 157, 157]
  line "Compile" [665, 523, 523, 523, 668, 668, 679]
  line "Eval" [617, 617, 617, 617, 351, 351, 167]
```

```mermaid
---
config:
  themeVariables:
    xyChart:
      plotColorPalette: "#D55E00"
---
xychart-beta
  title "medium: allocations during Render"
  x-axis ["v1.16.1", "v1.17.0", "cf3dc41*", "bcbc92c*", "29b002b*", "5360a31*", "d4264c5*"]
  y-axis "Objects" 0 --> 56000
  line "Render" [50337, 45413, 40292, 40301, 28449, 24007, 23587]
```

| Run | Lex | Parse | Compile | Eval | Render | Render with ActionView |
|---|--:|--:|--:|--:|--:|--:|
| v1.16.1 | 2,175 | 4,513 | 665 | 617 | 50,337 | 50,392 |
| v1.17.0 | 774 | 157 | 523 | 617 | 45,413 | 45,475 |
| cf3dc41* | 774 | 157 | 523 | 617 | 40,292 | 40,357 |
| bcbc92c* | 774 | 157 | 523 | 617 | 40,301 | 40,357 |
| 29b002b* | 774 | 157 | 668 | 351 | 28,449 | 28,507 |
| 5360a31* | 774 | 157 | 668 | 351 | 24,007 | 24,067 |
| d4264c5* | 774 | 157 | 679 | 167 | 23,587 | 23,646 |

### large

```mermaid
---
config:
  themeVariables:
    xyChart:
      plotColorPalette: "#0072B2, #E69F00, #009E73, #CC79A7"
---
xychart-beta
  title "large: allocations during Lex, Parse, Compile and Eval"
  x-axis ["v1.16.1", "v1.17.0", "cf3dc41*", "bcbc92c*", "29b002b*", "5360a31*", "d4264c5*"]
  y-axis "Objects" 0 --> 12000
  line "Lex" [5760, 1935, 1935, 1935, 1935, 1935, 1935]
  line "Parse" [10175, 338, 338, 338, 338, 338, 338]
  line "Compile" [1254, 1014, 1014, 1014, 1321, 1321, 1354]
  line "Eval" [1172, 1172, 1172, 1172, 605, 605, 407]
```

```mermaid
---
config:
  themeVariables:
    xyChart:
      plotColorPalette: "#D55E00"
---
xychart-beta
  title "large: allocations during Render"
  x-axis ["v1.16.1", "v1.17.0", "cf3dc41*", "bcbc92c*", "29b002b*", "5360a31*", "d4264c5*"]
  y-axis "Objects" 0 --> 120000
  line "Render" [101622, 94133, 87977, 87982, 65280, 40058, 39598]
```

| Run | Lex | Parse | Compile | Eval | Render | Render with ActionView |
|---|--:|--:|--:|--:|--:|--:|
| v1.16.1 | 5,760 | 10,175 | 1,254 | 1,172 | 101,622 | 101,679 |
| v1.17.0 | 1,935 | 338 | 1,014 | 1,172 | 94,133 | 94,190 |
| cf3dc41* | 1,935 | 338 | 1,014 | 1,172 | 87,977 | 88,031 |
| bcbc92c* | 1,935 | 338 | 1,014 | 1,172 | 87,982 | 88,028 |
| 29b002b* | 1,935 | 338 | 1,321 | 605 | 65,280 | 65,338 |
| 5360a31* | 1,935 | 338 | 1,321 | 605 | 40,058 | 40,121 |
| d4264c5* | 1,935 | 338 | 1,354 | 407 | 39,598 | 39,652 |


## Time per call

Times are only comparable between runs on the same machine, Ruby version and YJIT setting, so they are grouped by those.

### Apple M1 Pro, Darwin arm64, Ruby 3.4.12, YJIT disabled

#### small

```mermaid
---
config:
  themeVariables:
    xyChart:
      plotColorPalette: "#0072B2, #E69F00, #009E73, #CC79A7"
---
xychart-beta
  title "small: time during Lex, Parse, Compile and Eval"
  x-axis ["v1.16.1", "v1.17.0", "cf3dc41*", "bcbc92c*", "29b002b*", "5360a31*", "d4264c5*"]
  y-axis "ms" 0 --> 0.33
  line "Lex" [0.151, 0.051, 0.052, 0.051, 0.051, 0.051, 0.051]
  line "Parse" [0.248, 0.02, 0.02, 0.019, 0.019, 0.019, 0.02]
  line "Compile" [0.022, 0.024, 0.023, 0.023, 0.026, 0.026, 0.023]
  line "Eval" [0.297, 0.296, 0.296, 0.298, 0.269, 0.26, 0.13]
```

```mermaid
---
config:
  themeVariables:
    xyChart:
      plotColorPalette: "#D55E00"
---
xychart-beta
  title "small: time during Render"
  x-axis ["v1.16.1", "v1.17.0", "cf3dc41*", "bcbc92c*", "29b002b*", "5360a31*", "d4264c5*"]
  y-axis "ms" 0 --> 0.068
  line "Render" [0.061, 0.059, 0.047, 0.047, 0.037, 0.038, 0.037]
```

| Run | Lex | Parse | Compile | Eval | Render | Render with ActionView |
|---|--:|--:|--:|--:|--:|--:|
| v1.16.1 | 150.5 µs | 248.4 µs | 22.2 µs | 296.5 µs | 61.3 µs | 81.3 µs |
| v1.17.0 | 51.2 µs | 19.5 µs | 23.5 µs | 295.5 µs | 58.7 µs | 80.5 µs |
| cf3dc41* | 51.5 µs | 19.5 µs | 23.5 µs | 295.6 µs | 47.2 µs | 67.8 µs |
| bcbc92c* | 51.0 µs | 19.3 µs | 23.5 µs | 297.9 µs | 47.2 µs | 66.6 µs |
| 29b002b* | 50.9 µs | 19.4 µs | 26.1 µs | 269.3 µs | 37.4 µs | 57.4 µs |
| 5360a31* | 51.1 µs | 19.4 µs | 26.1 µs | 260.3 µs | 37.6 µs | 56.8 µs |
| d4264c5* | 51.0 µs | 19.7 µs | 23.2 µs | 129.6 µs | 36.9 µs | 57.7 µs |

#### medium

```mermaid
---
config:
  themeVariables:
    xyChart:
      plotColorPalette: "#0072B2, #E69F00, #009E73, #CC79A7"
---
xychart-beta
  title "medium: time during Lex, Parse, Compile and Eval"
  x-axis ["v1.16.1", "v1.17.0", "cf3dc41*", "bcbc92c*", "29b002b*", "5360a31*", "d4264c5*"]
  y-axis "ms" 0 --> 0.65
  line "Lex" [0.33, 0.109, 0.109, 0.108, 0.107, 0.108, 0.108]
  line "Parse" [0.539, 0.04, 0.04, 0.04, 0.04, 0.039, 0.04]
  line "Compile" [0.095, 0.089, 0.089, 0.089, 0.099, 0.099, 0.094]
  line "Eval" [0.59, 0.586, 0.585, 0.588, 0.526, 0.514, 0.289]
```

```mermaid
---
config:
  themeVariables:
    xyChart:
      plotColorPalette: "#D55E00"
---
xychart-beta
  title "medium: time during Render"
  x-axis ["v1.16.1", "v1.17.0", "cf3dc41*", "bcbc92c*", "29b002b*", "5360a31*", "d4264c5*"]
  y-axis "ms" 0 --> 18
  line "Render" [16.1, 16.19, 14.9, 14.18, 10.55, 4.356, 4.336]
```

| Run | Lex | Parse | Compile | Eval | Render | Render with ActionView |
|---|--:|--:|--:|--:|--:|--:|
| v1.16.1 | 329.8 µs | 538.9 µs | 94.7 µs | 589.7 µs | 16.10 ms | 16.12 ms |
| v1.17.0 | 108.6 µs | 40.0 µs | 89.5 µs | 585.5 µs | 16.19 ms | 16.26 ms |
| cf3dc41* | 108.8 µs | 40.0 µs | 89.2 µs | 585.0 µs | 14.90 ms | 14.78 ms |
| bcbc92c* | 107.7 µs | 39.5 µs | 89.1 µs | 587.6 µs | 14.18 ms | 14.27 ms |
| 29b002b* | 107.4 µs | 39.5 µs | 99.0 µs | 525.8 µs | 10.55 ms | 10.61 ms |
| 5360a31* | 108.4 µs | 39.5 µs | 98.6 µs | 513.9 µs | 4.36 ms | 4.40 ms |
| d4264c5* | 108.2 µs | 39.8 µs | 93.8 µs | 289.2 µs | 4.34 ms | 4.39 ms |

#### large

```mermaid
---
config:
  themeVariables:
    xyChart:
      plotColorPalette: "#0072B2, #E69F00, #009E73, #CC79A7"
---
xychart-beta
  title "large: time during Lex, Parse, Compile and Eval"
  x-axis ["v1.16.1", "v1.17.0", "cf3dc41*", "bcbc92c*", "29b002b*", "5360a31*", "d4264c5*"]
  y-axis "ms" 0 --> 1.4
  line "Lex" [0.897, 0.272, 0.273, 0.271, 0.27, 0.272, 0.271]
  line "Parse" [1.247, 0.091, 0.091, 0.09, 0.091, 0.091, 0.091]
  line "Compile" [0.186, 0.18, 0.18, 0.18, 0.187, 0.188, 0.184]
  line "Eval" [1.156, 1.15, 1.148, 1.152, 1.011, 0.987, 0.656]
```

```mermaid
---
config:
  themeVariables:
    xyChart:
      plotColorPalette: "#D55E00"
---
xychart-beta
  title "large: time during Render"
  x-axis ["v1.16.1", "v1.17.0", "cf3dc41*", "bcbc92c*", "29b002b*", "5360a31*", "d4264c5*"]
  y-axis "ms" 0 --> 59
  line "Render" [52.9, 52.33, 50.04, 49.93, 44.03, 7.697, 7.816]
```

| Run | Lex | Parse | Compile | Eval | Render | Render with ActionView |
|---|--:|--:|--:|--:|--:|--:|
| v1.16.1 | 896.9 µs | 1.25 ms | 186.2 µs | 1.16 ms | 52.90 ms | 53.01 ms |
| v1.17.0 | 272.3 µs | 90.7 µs | 179.7 µs | 1.15 ms | 52.33 ms | 52.21 ms |
| cf3dc41* | 272.9 µs | 91.1 µs | 180.4 µs | 1.15 ms | 50.04 ms | 50.05 ms |
| bcbc92c* | 270.7 µs | 90.5 µs | 180.1 µs | 1.15 ms | 49.93 ms | 50.13 ms |
| 29b002b* | 270.1 µs | 90.8 µs | 187.0 µs | 1.01 ms | 44.03 ms | 43.94 ms |
| 5360a31* | 272.4 µs | 90.9 µs | 187.6 µs | 987.1 µs | 7.70 ms | 7.75 ms |
| d4264c5* | 270.8 µs | 91.0 µs | 184.3 µs | 656.0 µs | 7.82 ms | 7.86 ms |

