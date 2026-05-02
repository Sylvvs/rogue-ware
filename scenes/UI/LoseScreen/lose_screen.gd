extends Control
var http_request : HTTPRequest
const SERVER_URL = "http://localhost/godot/db_test.php"
const SERVER_HEADERS = ["Content-Type: application/x-www-form-urlencoded", "Cache-Control: max-age=0"]
var request_queue : Array = []
var is_requesting : bool = false
var this_run_minigames : int = 0
var this_run_coins : int = 0
@onready var retry_button = $VBoxContainer/Retry
@onready var back_to_main_screen = $VBoxContainer/MainScreen
@onready var stats_label = $StatsLabel

func _ready() -> void:
	print("[LoseScreen] _ready start")
	http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.connect("request_completed", Callable(self, "_http_request_completed"))
	retry_button.text = "RETRY"
	back_to_main_screen.text = "BACK TO START SCREEN"
	this_run_minigames = Inventory.minigames_beaten
	this_run_coins = Inventory.coins
	print("[LoseScreen] Stats read — minigames: %d, coins: %d" % [this_run_minigames, this_run_coins])
	stats_label.text = _format_this_run()
	_save_run()
	print("[LoseScreen] _ready done, queue size: %d" % request_queue.size())

func _format_this_run() -> String:
	return (
		"Minigames beaten: %d\n" % this_run_minigames
		+ "Coins earned: %d\n" % this_run_coins
		+ "\n[Loading previous runs...]"
	)

func _format_full_stats(previous_runs: Array) -> String:
	var text = (
		"Minigames beaten: %d\n" % this_run_minigames
		+ "Coins earned: %d\n\n" % this_run_coins
	)
	if previous_runs.is_empty():
		text += "No previous runs found."
		return text
	text += "PREVIOUS RUNS\n"
	for i in previous_runs.size():
		var run = previous_runs[i]
		text += "#%d | %d minigames | %d coins\n" % [
			i + 1,
			int(run.get("minigames_beaten", 0)),
			int(run.get("coins_earned", 0))
		]
	return text

func _save_run():
	print("[LoseScreen] Queuing add_run")
	var command = "add_run"
	var data = {
		"minigames_beaten": this_run_minigames,
		"coins_earned": this_run_coins
	}
	request_queue.push_back({"command": command, "data": data, "on_complete": "_on_run_saved"})

func _fetch_runs():
	print("[LoseScreen] Queuing get_runs")
	var command = "get_runs"
	var data = {"limit": 10}
	request_queue.push_back({"command": command, "data": data, "on_complete": "_on_runs_fetched"})

func _process(_delta):
	if is_requesting:
		return
	if request_queue.is_empty():
		return
	print("[LoseScreen] _process: picking up request, queue size before pop: %d" % request_queue.size())
	is_requesting = true
	_send_request(request_queue.pop_front())

func _send_request(request: Dictionary):
	var client = HTTPClient.new()
	var data = client.query_string_from_dict({"data": JSON.stringify(request["data"])})
	var body = "command=" + request["command"] + "&" + data
	print("[LoseScreen] Sending request — command: %s | body: %s" % [request["command"], body])
	var err = http_request.request(SERVER_URL, SERVER_HEADERS, HTTPClient.METHOD_POST, body)
	if err != OK:
		printerr("[LoseScreen] HTTPRequest.request() error code: %d" % err)
		is_requesting = false
		return
	print("[LoseScreen] Request sent OK, waiting for response...")
	http_request.set_meta("on_complete", request.get("on_complete", ""))

func _http_request_completed(result, response_code, body):
	var callback = http_request.get_meta("on_complete", "")
	print("[LoseScreen] Response received — result: %d | code: %d | callback: %s" % [result, response_code, callback])
	is_requesting = false

	if result != HTTPRequest.RESULT_SUCCESS or response_code != 200:
		printerr("[LoseScreen] Request failed: result=%d code=%d" % [result, response_code])
		return

	var text = body.get_string_from_utf8()
	print("[LoseScreen] Raw response body: %s" % text)

	var json = JSON.new()
	if json.parse(text) != OK:
		printerr("[LoseScreen] JSON parse failed on: %s" % text)
		return

	var parsed = json.get_data()
	print("[LoseScreen] Parsed response type: %s | value: %s" % [typeof(parsed), str(parsed)])

	if callback == "_on_run_saved":
		_on_run_saved(parsed)
	elif callback == "_on_runs_fetched":
		_on_runs_fetched(parsed)
	else:
		printerr("[LoseScreen] Unknown callback: '%s'" % callback)

func _on_run_saved(data):
	print("[LoseScreen] _on_run_saved called with: %s" % str(data))
	_fetch_runs()

func _on_runs_fetched(data):
	print("[LoseScreen] _on_runs_fetched called with: %s" % str(data))
	var runs : Array = []
	if data is Dictionary and data.has("response"):
		var r = data["response"]
		print("[LoseScreen] 'response' field type: %d | value: %s" % [typeof(r), str(r)])
		if r is Array:
			runs = r
		else:
			printerr("[LoseScreen] 'response' is not an Array, it's type %d" % typeof(r))
	else:
		printerr("[LoseScreen] data has no 'response' key, or is not a Dictionary. Type: %d" % typeof(data))
	print("[LoseScreen] Final runs array size: %d" % runs.size())
	stats_label.text = _format_full_stats(runs)

func _on_retry_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/GameHandler.tscn")
func _on_main_screen_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/UI/StartScreen/start_screen.tscn")
