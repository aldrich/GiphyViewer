# Giphy Viewer

It's a project that uses the Giphy API to load and display trending GIFs.

### Feature List

- [x] Smooth scrolling on device (no stutter on iPhone XS Max)
- [x] 20 pages loaded on startup, with 25 GIFs each page
- [x] multi-column display (# of columns adapts based on screen orientation and device size)
- [x] single GIF full screen display
- [x] save GIF to gallery
- [x] progressive loading
- [x] optimized bandwidth and CPU usage...loads and displays still image until original GIF is fully loaded

### Frameworks

- Gifu
- Snapkit

### Architectures

- MVVM-C

### Directions

Tested on Xcode 11.3. Minimum version supported is iOS 13.

1. Run `pod install` to load the dependencies
2. Open `.xcworkspace` file with Xcode 11.
3. Review and run the unit tests and UI tests.

### Limitations / Future Work

- If you scroll very quickly and the network is slow you may begin to see GIFs loaded in cells that are from a previously loaded GIF
- Should be able to cache visited GIF screens so they won't need to be loaded again
- Turning phone to landscape scrolls it back to the top. Preferably it should preserve scroll order.
- Handle no internet / API errors more gracefully.
- Show download progress for the original GIF.
