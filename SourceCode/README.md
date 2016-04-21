# VoiceLocker Info

VoiceLocker is a Web-based application intended to securely store sensitive data for it's users in the form of text files.

When creating an account with VoiceLocker, the user will enter a username, password, passphrase, and record themselves saving the passphrase on submit.

CMUPocketsphinx is used to decode speech from the internal microphone into text, while Chromaprint uses the raw audio data file created by
CMUPocketsphinx to create an austic model or fingerprint to be stored and verify a user's identity on login. The threshold can be raised or lowered
depending on how accurate you want the users to sound like their original recorded passphrase. A lower threshold may result in another user, who says the correct password and passphrase,
gaining access to the sensitive files even though their voice and pronounciation may be different.

Encryption is handled by the 3DES python scrip in the lib/assests/python folder. Ruby executes shell commands, such as python, using the backticks and returns anything printed by the script.
When the user creates a file or new fingerprint, their hashed passphrase and username are used to generate the key
to encrypt and decrypt their files. This is a symmetric form of encryption.

Every time a user creates, edits, updates, or desroys a text file, they must say their passphrase. This may seem inconvenient, but with respectable recording equipment this algorithm gaurentees
privacy and adds less than 5 seconds to the users process.

This current build still includes many testing variables and lines. This current build allows users all acccess as described, but may throw rails errors when users enter a username that is invalid.

The database is an sqlite3 database, integrated into Rails with ActiveRecord. Currently there are two used tables, users and text_files. Users contains attributes such as id, username,
password_digest(the hashed password), created_at, updated_at, passphrase_text (the hashed passphrase chosen at account creation), passphrase_recording (used for test users to save the path to their file),
and the passphrase_fingerprint (an encrypted json which holds the compressed fingerbring and byte array fingerprint).

The text_files table holds attributes for the text_file model such as id, title (encrypted), text (encrypted), crated_at, updated_at, and user_id (foreign key referring to id of user in users table).

VoiceLocker git repo: https://github.com/sgstuard/VoiceLocker


# VoiceLocker Deployment

VoiceLocker depends on some libraries, mainly PocketSphinx and Chromaprint. First, follow the guide below to install pocketsphinx(including the Sphinxbase lib). These libraries include multiple
dependencies as well such as bison, python-dev, and the developer package for pulseaudio. Install the libchromaprint-dev library as well. Once installed, the user must add the following gems to their Gemfile: 'json', 'pocketsphinx-ruby, and
'chromaprint'. Run bundle install to verify they are added.

Use the 'rails: server' command from the root directory of VoiceLocker to host the site on localhost:3000.


# Resources

To install pocketsphinx and dependencies: http://cmusphinx.sourceforge.net/wiki/tutorialpocketsphinx
pocketsphinx-ruby: https://github.com/watsonbox/pocketsphinx-ruby
chromaprint: https://github.com/TMXCredit/chromaprint

# Contributions

All files included in the SourceCode folder are files that we created or edited. Unless otherwise noted, most of the code contained in these files was written by us. 