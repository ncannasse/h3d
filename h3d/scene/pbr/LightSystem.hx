package h3d.scene.pbr;

@:access(h3d.scene.pbr.Light)
class LightSystem extends h3d.scene.LightSystem {

	override function computeLight( obj : h3d.scene.Object, shaders : hxsl.ShaderList ) : hxsl.ShaderList {
		var light = Std.instance(obj, h3d.scene.pbr.Light);
		if( light != null ) {
			shaders = ctx.allocShaderList(light.shader, shaders);
			if( light.shadows.shader != null && light.shadows.mode != None )
				shaders = ctx.allocShaderList(light.shadows.shader, shaders);
		}
		return shaders;
	}

	/**
		This can be overriden in order to mark meshes as culled=true so their shadows
		doesn't get drawn for this specific light.
	**/
	public function cullObjectsForLight( light : Light ) {
	}

	public function drawLight( light : Light, passes : h3d.pass.PassList ) {
		light.shadows.setContext(ctx);
		cullObjectsForLight(light);
		passes.filter(function(p) return !p.obj.culled);
		light.shadows.draw(passes);
		for( p in passes.getFiltered() )
			p.obj.culled = false;
		passes.reset();
	}

	public function drawScreenLights( r : h3d.scene.Renderer, lightPass : h3d.pass.ScreenFx<Dynamic> ) {
		var plight = @:privateAccess ctx.lights;
		var currentTarget = ctx.engine.getCurrentTarget();
		var width = currentTarget == null ? ctx.engine.width : currentTarget.width;
		var height = currentTarget == null ? ctx.engine.height : currentTarget.height;
		while( plight != null ) {
			var light = Std.instance(plight, h3d.scene.pbr.Light);
			if( light != null && light.primitive == null ) {
				if( light.shadows.shader != null ) lightPass.addShader(light.shadows.shader);
				lightPass.addShader(light.shader);
				lightPass.render();
				lightPass.removeShader(light.shader);
				if( light.shadows.shader != null ) lightPass.removeShader(light.shadows.shader);
			}
			plight = plight.next;
		}
	}
}
