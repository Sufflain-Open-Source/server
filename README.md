# Sufflain's server-side application

Licensed under the **GNU AGPLv3**. For more, read the [LICENSE](./LICENSE) file.

## Project configuration
### Firebase
1. Create a user with an Email provider.
2. Make sure that Firebase Realtime Database write permissions are allowed *only* for a user with a 
specific UID.
### Config file
1. Copy the program's config file from the [template](./template) directory to *$HOME/.config*.
2. Fill it with necessary data for writing to the database.
    - user: User credentials that will allow the application to perform authenticated requests to 
    the Realtime Database.

    - database: Necessary info about the database.

## Commit Message Guidelines
We use [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) to format our commit
messages.