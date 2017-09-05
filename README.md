# secretman

Tools for managing secrets with Yubikey. This is a work-in-progress at the moment, but may become something like a tutorial or Proof-of-Concept. We'll see.

This is not a review of the product, just my notes about using it for practical purposes. I have identified several use-cases and tried to cover these case by case.


## What is Yubikey

[Yubikey](https://www.yubico.com/products/yubikey-hardware/) is a commercial product which can be used to some interesting and useful things, such as: 
encrypting files, signing data digitally and as a two-factor authentication mechanism. Effectively Yubikey is a hardware implementation which controls
access to the secret keys necessary for those feats and these secret keys can't be extracted. (At least, there are no known exploits or practical ways
to extract the keys or make a copy of the key).

Yubikey is not unique, there are other similar products emerging, such as [OnlyKey](https://www.amazon.com/OnlyKey-Color-Password-Manager-Obsolete/dp/B06Y1CSRZX) which
essentially is similar to Yubikey.


## Use-case 1: two-factor authentication, using FIDO U2F

The most common two-factor authentication is perhaps Google Authenticator used with a phone. SMS being perhaps the second most popular. RSA dongles work, but they
cost money and can't be used for anything else so they are out for most normal use cases.

FIDO U2F is a new standard and super simple way for user to authenticate actions for a web application. This [FIDO U2F tutorial](https://fidoalliance.org/assets/downloads/FIDO-U2F-UAF-Tutorial-v1.pdf) explains how it works internally. The important thing is that a web browser (and web application) is allowed to talk with FIDO U2F compliant USB device without resorting to complicated things like WebUSB. 

Compared to phone, this is better from the security point of view.

Yubikey supports other authentication mechanisms and can be used to emulate Google Authenticator, but FIDO U2F is usable for normal people without technical knowledge.


## Technical preparations and precautions

Being a programmer I want the solution to support command line access and automation as much as possible. Also, one must plan for the possibility that Yubikey is lost or destroyed for some reason. There must be a way to recover and one should test the recovery plan in advance to make sure it actually works.

There are multiple tutorials about these things, here are some I used as a reference:
* (https://github.com/drduh/YubiKey-Guide)
* (https://florin.myip.org/blog/easy-multifactor-authentication-ssh-using-yubikey-neo-tokens)
* (https://blog.liw.fi/posts/2017/05/29/using_a_yubikey_4_for_ensafening_one_s_encryption/)

Here's a short summary. I use a Mac, so all steps are not appropriate for Linux or Windows, ability to reason required.

### Install necessary software

* Install GPG (OpenPGP). Make sure it's v2 to support 4096 bit keys.
* Install pinentry program (with Mac at least)

(Assumed that you are using Homebrew, but you almost certainly are if you are a developer working with a Mac)

See (https://github.com/Homebrew/homebrew-core/issues/14737)
´´´
brew install pinentry-mac
echo "pinentry-program /usr/local/bin/pinentry-mac" >> ~/.gnupg/gpg-agent.conf
´´´

### Generate keys

See (https://blog.liw.fi/posts/2017/05/29/using_a_yubikey_4_for_ensafening_one_s_encryption/) for a good reference.

* Make backup copies of the keys 
´´´
gpg --armor --export
gpg --armor --export-secret-key
´´´

Put these into a safe place, not connected to anything or powered up. If (when) you lose your Yubikey, these are the only way to recover or create a new Yubikey with the same secret keys. Consider that you could lose these too in a catastrophe and USB sticks and other things deteoriate over time.

* Move keys to the Yubikey "smart card"

´´´
gpg --edit-key XXXX
´´´

select keys one at a time, transfer and save

* Make sure everything is ok

´´´
gpg --card-status
gpg --list-secret-keys
´´´

keylisting should show > for the moved keys.

### Set Yubi PIN codes

Set admin PIN and normal user PIN. Try not to forget these or you will be totally locked out. 





## Use-case 2: File encryption

File encryption is based on the smart card properties of the card. This means user needs to install enough software to talk to smart cards and there are several alternatives to doing this. See [Yubico articles on OpenPGP](https://www.yubico.com/support/knowledge-base/categories/articles/use-yubikey-openpgp/).

Being a programmer I want a solution



## Use-case 3: Secure SSH authentication



## Use-case 4: Signing data and files

TODO

## Use-case 5: two-factor authentication, without FIDO U2F

TODO


