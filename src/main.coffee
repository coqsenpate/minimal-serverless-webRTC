import './styles'
import '../node_modules/bootstrap/scss/bootstrap'
import $ from 'jquery'
import _ from 'lodash'

console.log 'Doin\' it right'

dataChanel1 = dataChannel2 = null

# cfg =
# 	"iceServers":[{"url":"stun:23.21.150.121"}]
# con =
# 	'optional': [{'DtlsSrtpKeyAgreement': true}]

$('#createRoomBtn').on 'click', ->
	handleClickOnCreateRoomBtn()

$('#joinRoomBtn').on 'click', ->
	handleClickOnJoinRoomBtn()

createPeerConnection = ->
	# pc = new RTCPeerConnection cfg, con
	pc = new RTCPeerConnection()
	pc.ondatachannel = (event)-> console.log '>> On data channel event', event
	pc.onsignalingstatechange = (event)-> console.log '>> Signaling state change event', event
	pc.onconnection = (event)-> console.log '>> Connection event', event
	pc.oniceconnectionstatechange = (event)-> console.log '>> ICE connection state change event', event
	pc.onicegatheringstatechange = (event)-> console.log '>> ICE gathering state change', event
	pc.onsignalingstatechange = (event)-> console.log '>> Signaling state change event', event
	pc

createDataChannel = (pc, chanName)->
	dc = pc.createDataChannel chanName, {reliable:true}
	dc.onclose = -> console.log 'DataChannel closed'
	dc.onerror = (err)-> console.log 'DataChannel error', err

	dc.onopen = ->
		console.log 'DataChannel open'
		dcLabel = dc.label
		$("[data-channelLabel=\"#{dcLabel}\"]").on 'click', ->
			msg = $('#chatInput').val()
			console.log '>> Sending...', msg
			dc.send msg

	dc.onmessage = (e)->
		console.log '>> Message event!', e.msg

	dc

createOffer = (pc)->
	console.log '> Creating offer'
	isNegotiating = false
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

sendDataToPeer = (dc, data)->
	dc.send data

handleClickOnCreateRoomBtn = ->
	pc1 = createPeerConnection()
	dataChannel1 = createDataChannel pc1, 'dataChannel1'
	createOffer(pc1).then((offer)->
		setLocalDescription(pc1, offer).then ->

			# Setup will resume on null-icecandidate event
			pc1.onicecandidate = (e)->
				console.log '>> pc1 ICE candidate event', e
				unless e.candidate is null
					console.log '>> pc1: Treating non-null ICE candidate...'
				else
					console.log '>> pc1: ICE candidates treatment over'
					$('#offerOutput').val JSON.stringify(pc1.localDescription)

			$('#join1').on 'click', ->
				answer = JSON.parse($('#answerInput').val())
				setRemoteDescription(pc1, answer)

	).catch (err)->
		console.log 'Error setting up peerConnection1:', err

handleClickOnJoinRoomBtn = ->
	pc2 = createPeerConnection()
	dataChannel2 = createDataChannel pc2, 'dataChannel2'

	offer = JSON.parse($('#offerInput').val())
	setRemoteDescription(pc2, offer).then( ->

		createAnswer(pc2).then (answer)->
			setLocalDescription(pc2, answer).then ->

				# Setup will resume on null-icecandidate event
				pc2.onicecandidate = (e)->
					console.log '>> pc2 ICE candidate event', e
					unless e.candidate is null
						console.log '>> pc2: Treating non-null ICE candidate'
					else
						console.log '>> pc2: ICE candidates treatment over'
						$('#answerOutput').val JSON.stringify(pc2.localDescription)
						# setRemoteDescription(pc1, pc2.localDescription).then ->
						#
						# 	console.log '> All descriptors set. Channels:', dataChannel1, dataChannel2
	).catch (err)->
		console.log 'Error setting up peerConnection2:', err
