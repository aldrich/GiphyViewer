# Giphy Viewer

It's a project that uses the Giphy API to load and display trending GIFs.

### Feature List

- [x] 20 pages initially loaded, with 25 GIFs each
- [x] multi-column display
- [x] full screen display
- [x] save to gallery
- [x] progressive loading
- [x] optimized bandwidth and CPU usage

### Frameworks

- Gifu
- Snapkit

### Directions

Tested on Xcode 11.3. Minimum version supported is iOS 13.

1. Run `pod install` to load the dependencies
2. Open `.xcworkspace` file with Xcode 11.


### Limitations

- If you scroll very quickly and the network is slow you may begin to see GIFs loaded in cells that are from a previously loaded GIF
