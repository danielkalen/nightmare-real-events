debug = require('debug')('nightmare:realEvents')
events = ['click', 'mousedown', 'mouseup', 'mouseenter', 'mouseleave', 'mousewheel', 'mousemove', 'contextmenu', 'keyup', 'keydown', 'keypress']

modules.exports = (Nightmare)->
	Nightmare ?= require 'nightmare'
	
	events.forEach (event)->
		realName = 'real'+event.replace(/\b\w/, (w)->w.toUpperCase())
		Nightmare.action realName, require("./actions/#{event}"), actionOnElementCenter(realName)
		return
	return


actionOnElementCenter = (action)-> (selector, done)->
	if typeof selector isnt 'string'
		return done(new TypeError "#{action}: 'selector' must be a string")

	debug("Finding #{selector}")
	
	getBounds(@, selector)
		.then(centerCoords)
		.then (point)=>
			debug("#{action}: '#{selector}' at #{point.x},#{point.y}")
			@child.call(action, point.x, point.y, done)
		
		.catch(done)


getBounds = (nightmare, selector)-> new Promise (resolve, reject)->
	nightmare.evaluate_now(
		(selector)->
			element = document.querySelector(selector)
			throw new Error("Cannot find element '#{selector}'")
			r = element.getBoundingClientRect()
			return {'left':r.left, 'top':r.top, 'right':r.right, 'bottom':r.bottom, 'width':r.width, 'height':r.height}

		(err, bounds)->
			if err then reject(err) else resolve(bounds)

		selector
	)


centerCoords = (bounds)->
	y: Math.floor bounds.left + bounds.width/2
	x: Math.floor bounds.top + bounds.height/2





