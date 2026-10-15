class_name TestCase
extends RefCounted
## Base class for tests. Any method starting with "test_" is run by
## tests/run_tests.gd. Use the check_* helpers; failures are collected.

var failures: Array[String] = []
var current_test: String = ""


func check(condition: bool, message: String = "check failed") -> void:
	if not condition:
		failures.append("%s: %s" % [current_test, message])


func check_eq(actual: Variant, expected: Variant, message: String = "") -> void:
	if typeof(actual) in [TYPE_INT, TYPE_FLOAT] and typeof(expected) in [TYPE_INT, TYPE_FLOAT]:
		if not is_equal_approx(float(actual), float(expected)):
			failures.append("%s: expected %s, got %s %s" % [current_test, expected, actual, message])
	elif actual != expected:
		failures.append("%s: expected %s, got %s %s" % [current_test, expected, actual, message])


## Optional per-test setup.
func before_each() -> void:
	pass
