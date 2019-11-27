import './styles'
import '../node_modules/bootstrap/scss/bootstrap'
import $ from 'jquery'
import _ from 'lodash'

console.log 'Doin\' it right'

dataChannels = []
# peerDataChannels = []

$('#createOfferBtn').on 'click', ->
	handleClickOnCreateOfferBtn()

$('#createAnswerBtn').on 'click', ->
	handleClickOnCreateAnswerBtn()

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

handleClickOnCreateOfferBtn = ->
	pc = createPeerConnection()
	id = dataChannels.length
	dataChannels.push createDataChannel(pc, "dataChannel_#{id}")

	createOffer(pc).then((offer)->
		setLocalDescription(pc, offer).then ->
			pc.onicecandidate = (e)->
				if e.candidate is null
					# Event with null candidate signals that ice candidates gathering is over
					$('#offerOutput').val JSON.stringify(pc.localDescription)

			$('#setAnswerBtn').on 'click', ->
				answer = JSON.parse($('#answerInput').val())
				setRemoteDescription(pc, answer)

	).catch (err)->
		console.log 'Error setting up peerConnection1:', err

handleClickOnCreateAnswerBtn = ->
	pc = createPeerConnection()

	offer = JSON.parse($('#offerInput').val())
	setRemoteDescription(pc, offer).then( ->
		createAnswer(pc).then (answer)->
			setLocalDescription(pc, answer).then ->

				pc.onicecandidate = (e)->
					if e.candidate is null
						# Event with null candidate signals that ice candidates gathering is over
						$('#answerOutput').val JSON.stringify(pc.localDescription)
	).catch (err)->
		console.log 'Error setting up peerConnection2:', err
