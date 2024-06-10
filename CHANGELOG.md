## 1.1.1

* Fix hasVisualOverflow
* Remove unused platform directories

## 1.1.0

* Move creation of CurvedAnimation to didUpdateWidget
* Add sticky header case to example
* Fix usage without header
* Fix translationOffset not passed to SliverExpandable by AnimatedSliverExpandable

## 1.0.0

* Ability to use without a header
* **Breaking Changes**:
    * `AnimatedSliverExpandable` no longer performs toggling the state and instead a boolean value for `expanded` should be provided
    * `SliverExpandableHeaderBuilder` signature changed to drop the `onToggle` callback

## 0.0.1

* Initial release
