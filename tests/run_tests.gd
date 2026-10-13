extends SceneTree
## Runs every tests/test_*.gd file headlessly.
##
##   godot --headless --path . --script res://tests/run_tests.gd
##
## Exits with code 0 when everything passes, 1 otherwise.

const TEST_DIR := "res://tests"


func _initialize() -> void:
	var total := 0
	var failed: Array[String] = []
	var files := DirAccess.get_files_at(TEST_DIR)
	files.sort()
	for f in files:
		if not (f.begins_with("test_") and f.ends_with(".gd")) or f == "test_case.gd":
			continue
		var script: GDScript = load(TEST_DIR + "/" + f)
		if script == null or not script.can_instantiate():
			# A script that doesn't compile must fail the run, not be skipped.
			failed.append("%s: failed to load or compile (see errors above)" % f)
			print("FAIL  ", f, " did not compile")
			continue
		var suite: TestCase = script.new()
		for m in suite.get_method_list():
			var name: String = m["name"]
			if not name.begins_with("test_"):
				continue
			total += 1
			suite.current_test = "%s::%s" % [f.get_basename(), name]
			var before := suite.failures.size()
			suite.before_each()
			suite.call(name)
			if suite.failures.size() > before:
				print("FAIL  ", suite.current_test)
			else:
				print("ok    ", suite.current_test)
		failed.append_array(suite.failures)
	print("")
	for msg in failed:
		print("  - ", msg)
	print("%d tests, %d failed checks" % [total, failed.size()])
	quit(1 if failed.size() > 0 else 0)
