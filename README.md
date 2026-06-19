# Osmos Ads Flutter Demo

Flutter Android demo for the Osmos Ads assignment. The app fetches a banner ad,
renders the image, tracks impression visibility, tracks clicks, and shows clear
loading and failure states without using any state management package.

## Setup

1. Install Flutter with Android tooling.
2. From the project root, run `flutter pub get`.
3. Connect an Android device or start an emulator.

## Architecture

The code is split into simple folders:

- `lib/models` contains `AdBanner`.
- `lib/services` contains `OsmosSdkService`, `AdService`, and `AnalyticsService`.
- `lib/helpers` contains reusable visibility threshold logic.
- `lib/widgets` contains `BannerAdWidget`, `LoadingWidget`, and the reusable ad error widget.
- `lib/screens` contains `HomeScreen`.

`OsmosSdkService` owns the Osmos constants and network/tracking calls:

- `clientId = 10088010`
- `productAdsHost = demo.o-s.io`
- `displayAdsHost = demo-ba.o-s.io`
- `cliUbid = Any`
- `pageType = demo_page`
- `adUnit = banner_ads`

`AdService` converts the raw response into the app model by reading
`ads.banner_ads[0]`, then mapping `elements.value`, `elements.destination_url`,
`impression_tracking_url`, and `click_tracking_url`.

## Impression Tracking

`BannerAdWidget` uses `visibility_detector` and delegates the threshold check to
`VisibilityTrackingHelper`. An impression fires when `visibleFraction >= 0.5`.
`HomeScreen` stores `_hasFiredImpression`, so each loaded ad fires at most once.
Loading a new ad resets the flag.

## Click Tracking

When the banner is tapped, the app first sends the click tracking request through
`OsmosSdkService.fireClick`, logs `Click Fired`, and then opens
`destinationUrl` using `url_launcher` with `LaunchMode.externalApplication`.

## Analytics

`AnalyticsService` writes simple debug logs for:

- Ad Loaded
- Ad Failed
- Impression Fired
- Click Fired

The same status is reflected in the UI where useful.

## Error Handling

The app handles SDK initialization errors, failed network responses, empty ad
responses, missing `ads.banner_ads`, and invalid URL fields. Failures show
`Ad not available` with a retry button. Duplicate ad fetches are prevented while
the current request is in flight.


## How To Run

```bash
flutter pub get
flutter run
```

For static checks:

```bash
flutter analyze
flutter test
```

## Challenges And Edge Cases

- Visibility callbacks can fire repeatedly, so impression state lives outside
  the widget and is guarded before tracking.
- Invalid or partial ad payloads are rejected before rendering.
- Slow tracking calls are isolated from the UI state so the screen remains
  responsive.
