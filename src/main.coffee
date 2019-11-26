import './styles'
import '../node_modules/bootstrap/scss/bootstrap'
import $ from 'jquery'
import _ from 'lodash'

console.log 'Doin\' it right'

channel = {}

$('#createRoomBtn').on 'click', ->
	peerConnection1 = new RTCPeerConnection()
	peerConnection1.onDatachannel = (event)-> console.log '>> On data channel event', event
	peerConnection1.onsignalingstatechange = (event)-> console.log '>> Signaling state change event', event

	isNegotiating = false
	peerConnection1.createOffer().then((offer)->
		console.log '>> Offer created, waiting for connection...'
		peerConnection1.setLocalDescription offer

		$('#offerOutput').val JSON.stringify(offer)

		$('#join1').on 'click', ->
			unless isNegotiating
				isNegotiating = true
				answer = new RTCSessionDescription JSON.parse($('#answerInput').val())
				console.log '>> Got answer:', answer
				peerConnection1.setRemoteDescription(answer).then ->
					console.log '> Remote peer description set!', peerConnection1
					channel1 = peerConnection1.createDataChannel 'myDataChannel'
					channel1.onopen = -> console.log 'channel1 open'
					channel1.onclose = -> console.log 'channel1 closed'
					channel1.onerror = (err)-> console.log 'channel1 error', err
					channel1.onmessage = (event)-> console.log '>> Message event!', event
					console.log 'Data channel1 created:', channel1, channel1.readyState

					channel1.onmessage = (e)->
						console.log 'Message received!', e

					$('#send2chatBtn').on 'click', ->
						msg = $('#chatInput').val()
						console.log '>> Sending...', msg
						channel1.send msg
	).catch (err)->
		console.log 'Error creating RTC offer:', err


$('#joinRoomBtn').on 'click', ->
	unless _.isEmpty $('#offerInput').val()
		peerConnection2 = new RTCPeerConnection()
		peerConnection2.onDatachannel = (event)-> console.log '>> On data channel event', event
		peerConnection2.onsignalingstatechange = (event)-> console.log '>> Signaling state change event', event

		offer = new RTCSessionDescription JSON.parse($('#offerInput').val())
		console.log '>> Got offer:', offer
		peerConnection2.setRemoteDescription(offer).then ->
			console.log '> Remote peer description set.'
			peerConnection2.createAnswer().then((answer)->
				peerConnection2.setLocalDescription answer
				console.log '> Local peer description set.', peerConnection2
				$('#answerOutput').val JSON.stringify(answer)

				channel2 = peerConnection2.createDataChannel 'myDataChannel'
				channel2.onopen = -> console.log 'channel2 open'
				channel2.onclose = -> console.log 'channel2 closed'
				channel2.onerror = (err)-> console.log 'channel2 error', err
				channel2.onmessage = (event)-> console.log '>> Message event!', event

				console.log '>> Channel set:', channel2

				# $('#send2chatBtn').on 'click', ->
				# 	msg = $('#chatInput').val()
				# 	console.log '>> Sending...', msg
				# 	channel2.send msg

			).catch (err)->
				console.log 'Error creating RTC answer:', err
