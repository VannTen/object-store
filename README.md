# object-store

This is a very simple object storage server, done in Haskell to try the
language (it was for a take-home exercise).

## Building

You will need to use
[stack](https://docs.haskellstack.org/en/v2.7.3/install_and_upgrade/), one of
the Haskell build tools. It might build with Cabal but I did not test with it.

Once that's done, you'll need to run `stack install`, which will fetch all
necessary dependencies and build the executable in `build`.

You can also directly build and run with `stack run -- <program arguments>`

## Operation

The server use the filesystem to store its objects.
It assumes a working environment (good permissions, space left on device) and
will respond with errors 500 otherwise)

### API description

Upload object to the service
Request:  PUT /objects/{bucket}/{objectID}
Response:  Status: 201 Created {  "id": "<objectID>" }

Download an object from the service
Request: GET /objects/{bucket}/{objectID}
Response if object is found:  Status: 200 OK {object data}
Response if object is not found:  Status 400 Not Found

Delete an object from the service
Request:  DELETE /objects/{bucket}/{objectID}
Response if object found: Status: 200 OK
Response if object not found:  Status: 404 Not Found
