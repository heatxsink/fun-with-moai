MOAISim.openWindow ( "khan", 320, 480 )

viewport = MOAIViewport.new ()
viewport:setSize ( 320, 480 )
viewport:setScale ( 320, 480 )

layer = MOAILayer2D.new ()
layer:setViewport ( viewport )

MOAISim.pushRenderPass ( layer )

gfxQuad = MOAIGfxQuad2D.new ()
gfxQuad:setTexture ( "khan.jpg" )
gfxQuad:setRect ( -32, -32, 32, 32 )


-- set up the space and start its simulation
space = MOAICpSpace.new ()
space:setGravity ( 0, -1000 )
space:setIterations ( 5 )
space:start ()

-- attach the layer to the space for debug drawing
layer:setCpSpace ( space )

--polygon
poly = {
	-32, 32,
	32, 32,
	32, -32,
	-32, -32,
}

function makeThing ()

	mass = 1
	moment = MOAICpShape.momentForPolygon ( mass, poly )

	body = MOAICpBody.new ( 1, moment )
	space:insertPrim ( body )

	shape = body:addPolygon ( poly )
	shape:setElasticity ( 1.0 )
	shape:setFriction ( 0.2 )
	shape:setType ( 1 )
	shape.name = "thing"
	space:insertPrim ( shape )
	
	prop = MOAIProp2D.new ()
	prop:setDeck ( gfxQuad )
	layer:insertProp ( prop )
	
	-- attach the prop to the shape
	prop:setParent ( body )
end

function makeThings ( n )
	for i = 1, n do
		makeThing ()
	end
end

makeThings ( 20 )

-- set
layer:setCpSpace ( space )

--attache the prop to the shape
prop:setParent( body )

--set up the walls
staticbody = space:getStaticBody ()

function addSegment ( x0, y0, x1, y1 )
	shape = staticbody:addSegment ( x0, y0, x1, y1 )
	shape:setElasticity ( 1 )
	shape:setFriction ( 0.1 )
	shape:setType ( 2 )
	space:insertPrim ( shape )
end

addSegment ( -320, -240, 320, -240 )
addSegment ( -320, 240, 320, 240 )
addSegment ( -320, -240, -320, 240 )
addSegment ( 320, -240, 320, 240 )

mouseBody = MOAICpBody.new ( MOAICp.INFINITY, MOAICp.INIFINITY )

mouseX = 0
mouseY = 0

MOAIInputMgr.device.pointer:setCallback(
	function ( x, y )
		mouseX, mouseY = layer:wndToWorld ( x, y )
		mouseBody:setPos ( mouseX, mouseY )
	end
)

MOAIInputMgr.device.mouseLeft:setCallback (
	function ( down )
		if down then
			pick = space:shapeForPoint ( mouseX, mouseY )
			
			if pick then
				body = pick:getBody ()
				
				mouseJoint = MOAICpConstraint.newPivotJoint (
					mouseBody,
					body,
					0,
					0,
					body:worldToLocal( mouseX, mouseY )
				)
				mouseJoint:setMaxForce ( 50000 )
				mouseJoint:setBiasCoef ( 0.15 )
				space:insertPrim ( mouseJoint )
			end
		else
			if mouseJoint then
				space:removePrim ( mouseJoint )
				mouseJoint = nil
			end
		end
	end
)