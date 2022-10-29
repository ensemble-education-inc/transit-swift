# transit-swift

This is an _incomplete_ implementation of the [Transit](https://github.com/cognitect/transit-format) protocol for Swift.

## Basic Usage

	let value = try TransitDecoder().decode(SomeType.self, from: data)
	
	let data = try TransitEncoder().encode(value)

## Unsupported features

* Encoding
	* Encoding is not yet supported, but see the `encoder` branch.
* Int keys in maps
* String (not keyword) keys in maps
* `~z` special numbers
* `~c` characters
* Keyword cache rollover at 44^2 items
* JSON verbose mode

There is no plan to support these features, and pull requests are appreciated.