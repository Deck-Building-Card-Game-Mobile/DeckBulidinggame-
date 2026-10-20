class_name Keywords
extends RefCounted
## Keyword rules text for tap-to-explain on cards (Role 3 UI).
## Data lives in data/keywords.json (the "Keywords" tab of the sheet).
##
## Usage:  for kw in card_data.keywords: show_tooltip(kw, Keywords.get_rule(kw))

const KEYWORDS_PATH := "res://data/keywords.json"

static var _rules: Dictionary = {}   # keyword -> rule text


static func _ensure_loaded() -> void:
	if not _rules.is_empty():
		return
	for k in GameRules.load_json(KEYWORDS_PATH)["keywords"]:
		_rules[k["keyword"]] = k["rule"]


static func has_keyword(keyword: String) -> bool:
	_ensure_loaded()
	return _rules.has(keyword)


static func get_rule(keyword: String) -> String:
	_ensure_loaded()
	return _rules.get(keyword, "")


static func get_all() -> Dictionary:
	_ensure_loaded()
	return _rules.duplicate()
