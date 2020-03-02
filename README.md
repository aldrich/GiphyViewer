# Giphy Viewer

This is an iOS application that uses the Giphy API to load and display trending GIFs.

### Feature List

- [x] Smooth scrolling on device (no stutter on iPhone XS Max)
- [x] 20 pages loaded on startup, with 25 GIFs each page (can be configured)
- [x] multi-column display (# of columns adapts based on screen orientation and device size)
- [x] single GIF full screen display
- [x] save GIF to gallery
- [x] progressive loading and tiered network fetch priorities (GIFs still a few ways off in the list are downloaded in the background)
- [x] optimized bandwidth and CPU usage...loads and displays still image until original GIF is fully loaded

### 3rd Party Frameworks Used

- Gifu - used it to display animated GIFs on UIImageViews. It has a handy completion block for when the GIF is finally loaded.
- Snapkit - to make programmatic constraints easier to understand
- PINCache - used to support caching downloaded GIFs so you can instantly load the animation the next time around. Includes a method that can evict old entries automatically so the disk doesn't get filled up..

### Approaches and Patterns

These were written to support the idea of a robust app that is production-ready.

- MVVM-C
- Dependency Injection (in support of unit tests)
- Unit tests and UI tests
- Swift Extensions and Protocols

I researched on various online sources in order to accomplish specific requirements (e.g. collection view layouts, throttling) and when I could I provided links to the original sources in comments.

### Directions

Tested on Xcode 11.3. Minimum version supported is iOS 13.

1. Run `pod install` to load the dependencies
2. Open `.xcworkspace` file with Xcode 11.
3. Review and run the unit tests and UI tests.

### Issues / Limitations / Future Work

- Turning phone to landscape scrolls it back to the top. Preferably it should preserve scroll order.
- Handle no internet / API errors more gracefully.
- Show download progress indicators for the original GIF.
- More UI polish
