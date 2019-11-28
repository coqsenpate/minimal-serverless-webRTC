import './styles'
import '../node_modules/bootstrap/scss/bootstrap'
import $ from 'jquery'
import _ from 'lodash'

HIDDEN_CLASS = 'hidden'

dataChannels = []
testDataChannels = []

pcHost = null
pcPeer = null

$('#createOfferBtn').on 'click', ->
	createFullOffer()

$('#createAnswerBtn').on 'click', ->
	createFullAnswer()

$('#registerAnswerBtn').on 'click', ->
	registerAnswer()

$('#testBtn').on 'click', ->
	handleClickOnTestBtn()

$('#sendToChatBtn').on 'click', -> sendChatMsg()

$('#chatInput').on 'keyup', (e)->
	# Listen for 'Enter key'
	if e.keyCode is 13
		sendChatMsg()

sendChatMsg = ->
	msg = $('#chatInput').val()
	console.log '>> Sending message:', msg, getDataChannels()
	$('#chatInput').val ""
	appendToChatTextarea msg, "Us: "
	for dc in getDataChannels()
		if dc.readyState is 'open'
			dc.send msg

clearAllTextareas = ->
	$('textarea').val ""

getDataChannels = ->
	dataChannels

createPeerConnection = ->
	pc = new RTCPeerConnection()
	pc.ondatachannel = (event)->
		console.log '>> RECEIVED PEER DATACHANNEL!', event
		# Received peer datachannel: register it...
		dataChannels.push event.channel
		# Then set up chat message handler
		setDataChannelMessageHandler event.channel

		clearAllTextareas()

	pc.onconnection = (event)-> console.log '>> Connection event', event
	pc.onnegotiationneeded = (event)-> console.log '>> PC: Negotiation Needed event', event
	pc

setDataChannelMessageHandler = (dc)->
	dc.onmessage = (e)->
		msg = e.data
		console.log '>> Message received:', msg
		appendToChatTextarea msg, "Them: "

appendToChatTextarea = (msg, prefix)->
	$('#chatTextarea').val ($('#chatTextarea').val() + prefix + msg + "\n" )

createDataChannel = (pc, chanName)->
	dc = pc.createDataChannel chanName,
		reliable:true
	dc.onclose = -> console.log 'DataChannel closed'
	dc.onerror = (err)-> console.log 'DataChannel error', err
	dc.onopen = (e)->
		console.log '>>> DATACHANNEL OPEN <<<', e
		clearAllTextareas()

	setDataChannelMessageHandler dc

	dc

createOffer = (pc)->
	console.log '> Creating offer'
	pc.createOffer()

createAnswer = (pc)->
	console.log '> Creating answer'
	pc.createAnswer()

setLocalDescription = (pc, sessionDesc)->
	console.log '> Setting local description', sessionDesc
	pc.setLocalDescription sessionDesc

setRemoteDescription = (pc, sessionDesc)->
	console.log '> Setting remote description', sessionDesc
	pc.setRemoteDescription sessionDesc

createFullOffer = ->
	pcHost = createPeerConnection()
	id = dataChannels.length
	dataChannels.push createDataChannel(pcHost, "dataChannel_#{id}")

	offerPromise = createOffer(pcHost).then((offer)->
		setLocalDescription(pcHost, offer).then ->
			new Promise (resolve, reject)->
				pcHost.onicecandidate = (e)->
					if e.candidate is null
						# Event with null candidate signals that ice candidates gathering is over

						# We need to use pc.localDesc instead of offer to make this work!
						# THIS SEEMS IMPORTANT!
						$('#offerOutput').val JSON.stringify(pcHost.localDescription)
						resolve pcHost.localDescription
	).catch (err)->
		console.log 'Error setting up peerConnection1:', err

	offerPromise

createFullAnswer = (offer)->
	pcPeer = createPeerConnection()

	unless offer?
		offer = JSON.parse($('#offerInput').val())
	console.log '>> Got offer:', offer

	answerPromise = setRemoteDescription(pcPeer, offer).then( ->
		createAnswer(pcPeer).then (answer)->
			setLocalDescription(pcPeer, answer).then ->
				new Promise (resolve, reject)->
					pcPeer.onicecandidate = (e)->
						if e.candidate is null
							# Event with null candidate signals that ice candidates gathering is over

							# We need to use pc.localDesc instead of answer to make this work!
							# THIS SEEMS IMPORTANT!
							$('#answerOutput').val JSON.stringify(pcPeer.localDescription)
							resolve pcPeer.localDescription
	).catch (err)->
		console.log 'Error setting up peerConnection2:', err

	answerPromise

registerAnswer = (answer)->
	unless answer?
		answer = JSON.parse($('#answerInput').val())
	setRemoteDescription(pcHost, answer)


########################################################## 1-click and 1-page test setup

handleClickOnTestBtn = ->
	console.log '>> Launching test mode'
	$('.testPeerChat').removeClass HIDDEN_CLASS

	promise = createFullOffer()
	promise = promise.then (offer)->
		console.log '> Got offer:', offer
		$('#offerInput').val JSON.stringify(offer)

		createFullAnswer(offer).then (answer)->

			# Special handler for single page test
			pcPeer.ondatachannel = (event)->
				console.log '>> RECEIVED PEER DATACHANNEL!', event
				# Received peer datachannel: register it...
				testDataChannels.push event.channel
				# Then set up chat message handler
				setTestDataChannelMessageHandler event.channel

			$('#answerInput').val JSON.stringify(answer)

			registerAnswer(answer).then ->
				console.log '> Answer registered, let\'s roll'

########################################################## Handlers for 1-page test peer

$('#sendToChatBtn2').on 'click', -> sendChatMsg2()

$('#chatInput2').on 'keyup', (e)->
	# Listen for 'Enter key'
	if e.keyCode is 13
		sendChatMsg2()

sendChatMsg2 = ->
	msg = $('#chatInput2').val()
	console.log '>> Sending message:', msg, getDataChannels()
	$('#chatInput2').val ""
	appendToChatTextarea2 msg, "Us: "
	for dc in getTestDataChannels()
		if dc.readyState is 'open'
			dc.send msg

getTestDataChannels = ->
	testDataChannels

setTestDataChannelMessageHandler = (dc)->
	dc.onmessage = (e)->
		msg = e.data
		console.log '>> Message received:', msg
		appendToChatTextarea2 msg, "Them: "

appendToChatTextarea2 = (msg, prefix)->
	$('#chatTextarea2').val ($('#chatTextarea2').val() + prefix + msg + "\n" )
