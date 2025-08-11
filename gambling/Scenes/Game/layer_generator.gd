extends VoxelGeneratorScript

func _get_used_channels_mask() -> int:
	return VoxelBuffer.CHANNEL_SDF

#func _generate_block(out_buffer: VoxelBuffer, origin: Vector3i, lod: int) -> void:
	#if origin.y < 5:
		#out_buffer.set_voxel_f()

func sdfSphere(p: Vector3, s: float) -> float:
	return p.length() - s
