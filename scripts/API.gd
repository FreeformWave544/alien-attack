extends Node

var http_request : HTTPRequest
#var url = "http://localhost:3000"  # Replace with your API URL
var json_parser : JSON = JSON.new()  # Create a JSON instance

func _ready():
	# Initialize HTTPRequest node
	http_request = HTTPRequest.new()
	add_child(http_request)
	
	if not http_request.is_connected("request_completed", Callable(self, "_on_request_completed")):
		http_request.connect("request_completed", Callable(self, "_on_request_completed"))
	var post_data = {
		"diff": "easy",
		"score": 1916
	}
	send_request("POST", "/scores", post_data)

func send_request(method: String, endpoint: String, data: Dictionary = {}):
	var request_url = Global.url + endpoint
	if method.to_upper() == "POST":
		var json_data = JSON.stringify(data)
		var headers = ["Content-Type: application/json"]
		var post_status = http_request.request(request_url, headers, HTTPClient.METHOD_POST, json_data)
		print(post_status, " <- <- <- POST ERROR HERE, RIGHT THERE, YES THERE")
		if post_status != OK:
			print("POST request failed with error: ", post_status)
	elif method == "GET":
		var get_status = http_request.request(request_url)
		if get_status != OK:
			print("GET request failed with error: ", get_status)

func _on_request_completed(result, response_code, headers, body):
	print("Response Code:", response_code)
	var body_string = body.get_string_from_utf8()
	print("Full Response Body:", body_string)
	var data = JSON.parse_string(body_string)
	if response_code == 200:
		if data is Array:
			print("Processing Scores Data...")
			var scores_dict = {"easy": 0, "norm": 0, "hard": 0}
			for item in data:
				if item is Dictionary and item.has("diff") and item.has("score"):
					var diff = item["diff"]
					var score = item["score"]
					if diff == "easy":
						scores_dict["easy"] = score
					elif diff == "medium":
						scores_dict["norm"] = score
					elif diff == "hard":
						scores_dict["hard"] = score
			Global.set_scores(scores_dict)
		elif data is Dictionary and data.has("token"):
			Global.jwt_token = data["token"]
			print("JWT Token:", Global.jwt_token)
		else:
			print("Unexpected response format:", typeof(data))
	else:
		print("Request failed. Response code:", response_code)
