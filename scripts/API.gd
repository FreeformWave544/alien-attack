extends Node

var http_request : HTTPRequest
#var url = "http://localhost:3000"  # Replace with your API URL
var json_parser : JSON = JSON.new()  # Create a JSON instance

func _ready():
	# Initialize HTTPRequest node
	http_request = HTTPRequest.new()
	add_child(http_request)
	
	# Connect signal for when the request is complete
	http_request.connect("request_completed", Callable(self, "_on_request_completed"))
	
	# Example POST data
	var post_data = {
		"diff": "easy",
		"score": 1916
	}
	
	# Example: Send a POST request
	send_request("POST", "/scores", post_data)
	
	# Example: Send a GET request
	#send_request("GET", "/scores")

var good = true

# Function to send both GET and POST requests
func send_request(method: String, endpoint: String, data: Dictionary = {}):
	var request_url = Global.url + endpoint
	if method.to_upper() == "POST":
		# Convert the dictionary to a JSON string using JSON.stringify()
		var json_data = JSON.stringify(data)
		
		# Prepare headers for POST request
		var headers = ["Content-Type: application/json"]
		
		# Send POST request
		var post_error = http_request.request(request_url, headers, HTTPClient.METHOD_POST, json_data)
		if post_error != OK:
			print("POST request failed with error: ", post_error)
			good = false
	elif method == "GET":
		# Send GET request
		var get_error = http_request.request(request_url)
		if get_error != OK:
			print("GET request failed with error: ", get_error)

func _on_request_completed(result, response_code, headers, body):
	if response_code == 200:
		# Convert the body (PackedByteArray) to a String
		var body_string = body.get_string_from_utf8()

		# Decode the JSON response
		var parse_result = json_parser.parse(body_string)
		if parse_result == OK:
			var data = json_parser.get_data()  # Get the array
			print("Decoded JSON: ", data)
			if typeof(data) == TYPE_ARRAY:
				var scores_dict = {"easy": 0, "norm": 0, "hard": 0}
				for item in data:
					if item.has("diff") and item.has("score"):
						var diff = item["diff"]
						var score = item["score"]
						if diff == "easy":
							scores_dict["easy"] = score
						elif diff == "medium":
							scores_dict["norm"] = score
						elif diff == "hard":
							scores_dict["hard"] = score
				Global.set_scores(scores_dict)
			else:
				print("Error: Expected an array, but got: ", typeof(data))
		else:
			print("Failed to parse JSON: ", json_parser.get_error_message())
	else:
		print("Request failed. Response code: ", response_code)
