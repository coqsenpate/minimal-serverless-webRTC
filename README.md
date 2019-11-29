# minimal-serverless-webRTC

## Context
  This is a minimal and implementation webRTC:
  * No server and no signaling channel (copy and paste offer and answer from one browser window to another).
  * No ICE server declaration (this implementation is designed for use in a local network) and minimal handling of ICE candidates.
  * Setup and opening of dataChannels only (no audio or video stream).
  * Testing consists in chat-style text messages exchange.

## Installation
  1. Clone the git repo.
  2. Execute `$ npm install`

## Usage
  1. Launch dev server `$ npx webpack-dev-server`.
  2. Open browser windows at address `localhost:8080`.
  3. In first browser window, click **Create Offer** button and copy generated offer.
  4. In second browser window, paste offer in upper-right text area, click **Create Answer** button and copy generated answer.
  5. Back in first browser window, paste answer in lower-left textarea and click **Set Answer** button.
  6. webRTC dataChannel between the two browser windows should now be open; you can now use chat between the two browser window.
  7. Repeat process with another browser window to register another peer in the chat.

  Alternatively, you can test the whole offer/answer process automatically in a single window by clicking the **1-Click TEST** button.
