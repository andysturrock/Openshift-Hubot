# Openshift-Hubot
How to run Hubot on OpenShift

## Install and generate Hubot
Refer to the documentation: https://hubot.github.com/docs/
1. Install Hubot:  `npm install -g yo generator-hubot`.
2. Generate a Hubot instance:  `yo hubot`.  We'll use the Slack adapter, so either type that into the interactive generator or add `--adapter=slack` to the generator command line.  Also remember your Hubot's name. Note you can't call it hubot with lower case, but you can call it Hubot with upper case.  This guide assumes `yo hubot --owner="Andy Sturrock" --name="Hubot" --description="Hubot running on OpenShift with Slack adapter" --adapter=slack` was used to generate the Hubot.
3. Add Hubot to your Slack channel.  Follow the instructions here: https://slack.com/apps/A0F7XDU93-hubot
4. Make a note of the Slack API token.  It will look something like this: `xoxb-254033918276-29iq2774hZYHvlUE9LjP2HwH`. (That's an old one of mine so don't bother trying to use it!)
5. Test your Hubot is working by running on the command line: `HUBOT_SLACK_TOKEN=xoxb-254033918276-29iq2774hZYHvlUE9LjP2HwH ./bin/hubot --adapter slack`.  You should be able to type `@Hubot the rules` into your Slack channel (where Hubot is the name of your bot as per step 2) and you should see some output like this:
```
0. A robot may not harm humanity, or, by inaction, allow humanity to come to harm.
1. A robot may not injure a human being or, through inaction, allow a human being to come to harm.
2. A robot must obey any orders given to it by human beings, except where such orders would conflict with the First Law.
3. A robot must protect its own existence as long as such protection does not conflict with the First or Second Law.
```

## Edit the hubot config to run on OpenShift
1. OpenShift's Node image expects to start the command using `npm run -d start` so we need to add a `scripts` section to `package.json`.  It should look like this:
```
{
  "name": "bip",
  "version": "0.0.0",
  "private": true,
  "author": "hubot@sturrock.org",
  "description": "Hubot interface to BIP.",
  "dependencies": {
    "hubot": "^2.19.0",
    "hubot-diagnostics": "0.0.2",
    "hubot-google-images": "^0.2.7",
    "hubot-google-translate": "^0.2.1",
    "hubot-help": "^0.2.2",
    "hubot-heroku-keepalive": "^1.0.3",
    "hubot-maps": "0.0.3",
    "hubot-pugme": "^0.1.1",
    "hubot-redis-brain": "0.0.4",
    "hubot-rules": "^0.1.2",
    "hubot-scripts": "^2.17.2",
    "hubot-shipit": "^0.2.1",
    "hubot-slack": "^4.4.0"
  },
  "engines": {
    "node": "0.10.x"
  },
  "scripts": {
    "start": "hubot --adapter slack"
  }
}
```
Test this on the command line by running: `HUBOT_SLACK_TOKEN=xoxb-254033918276-29iq2774hZYHvlUE9LjP2HwH npm run -d start`.  If you do this be aware that ctrl-C may not kill the node process, so check using ps or task manager.
2. Push your changes to GitHub.

## Create the OpenShift config to run Hubot
1. Create an OpenShift Namespace/Project.
2. Create a Node.js deployment.
3. Create a secret to hold the Slack token.
    1. Base64 encode your Slack token: `echo -n "xoxb-254033918276-29iq2774hZYHvlUE9LjP2HwH" | base64`.
    2. Edit the secret.yml file to include the output.
    3. Upload the secret to OpenShift: `oc create -f secret.yml`
4. Edit the deployment config yaml to create an environment variable called HUBOT_SLACK_TOKEN from the secret.
    1. If there are any running pods, scale back to zero.
    2. Edit the containers section to add in the env part.  The deployment yaml should look like the the clip below.
    3. Scale your pods back to one.
    4. You can confirm the env var is set by opening a terminal on the pod and running `env | grep HUBOT_SLACK_TOKEN`.

```
...
    spec:
      containers:
        - env:
            - name: HUBOT_SLACK_TOKEN
              valueFrom:
                secretKeyRef:
                  key: hubot-slack-token
                  name: hubot-slack-token
          image: >-
            172.30.1.1:5000/hubot/hubot@sha256:f01dbcd31e7c1678a3430aabefcffe186223ea0453774eb92cf960879ac57cce
...
```

5. Check your pod logs for errors.
6. Test your Hubot by going back to your Slack channel and typing: `@hubot the rules`.
