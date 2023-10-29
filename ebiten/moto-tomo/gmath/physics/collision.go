package physics

import "github.com/solarlune/resolv"

func ObjectHasTag(obj *resolv.Object, tag string) bool {
	for _, objTag := range obj.Tags() {
		if objTag == tag {
			return true
		}
	}

	return false
}

func CollisionGetObjectWithTag(collision *resolv.Collision, tag string) *resolv.Object {
	for _, obj := range collision.Objects {
		if ObjectHasTag(obj, tag) {
			return obj
		}
	}

	return nil
}

func CollisionHasTag(collision *resolv.Collision, tag string) bool {
	objWithTag := CollisionGetObjectWithTag(collision, tag)

	return objWithTag != nil
}
