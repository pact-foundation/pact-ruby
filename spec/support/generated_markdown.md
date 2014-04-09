### A pact between Some Consumer and Some Provider

#### Requests from Some Consumer to Some Provider

* [A request for alligators](#a_request_for_alligators_given_alligators_exist) given alligators exist

* [A request for polar bears](#a_request_for_polar_bears)

#### Interactions

<a name="a_request_for_alligators_given_alligators_exist"></a>
Given **alligators exist**, upon receiving **a request for alligators** from Some Consumer, with
```json
{
  "method": "get",
  "path": "/alligators",
  "body": {
  }
}
```
Some Provider will respond with:
```json
{
  "headers": {
    "Content-Type": "application/json"
  },
  "status": 200,
  "body": {
    "alligators": [
      {
        "name": "Bob",
        "phoneNumber": "12345678"
      }
    ]
  }
}
```
<a name="a_request_for_polar_bears"></a>
Upon receiving **a request for polar bears** from Some Consumer, with
```json
{
  "method": "get",
  "path": "/polar-bears",
  "body": {
  }
}
```
Some Provider will respond with:
```json
{
  "headers": {
    "Content-Type": "application/json"
  },
  "status": 404,
  "body": {
    "message": "Sorry, due to climate change, the polar bears are currently unavailable."
  }
}
```
