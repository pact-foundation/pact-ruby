require 'colored'

puts "Key: #{'-'.red} expected, #{'+'.green} actual"

puts '{
  "_embedded": {'
puts '-      "events": [
-        {
-          "probability": "75",
-          "timestamp": "2014-03-03T14:00:00+00:00",
-          "_embedded": {
-            "opportunity": {
-              "displayAdvertising": true,
-              "_links": {
-                "self": {
-                  "href": "http://media-opportunities/opportunity-id-1"
-                },
-                "mediaProject": {
-                  "href": "http://media-projects/project-id-1"
-                }
-              }
-            }
-          }
-        }
-      ]'.red
puts '+    {
+    }'.green
puts '  }
}'

