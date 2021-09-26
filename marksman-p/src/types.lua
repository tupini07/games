--- @class Bullseye
--- @field public x number x coordinates of top left
--- @field public y number y coordinates of top left
--- @field public sprite_x number x coords of sprite
--- @field public sprite_y number y coords of sprite
--- @field public hitbox_x number x coords of hitbox
--- @field public hitbox_y number y coords of hitbox
--- @field public hitbox_w number width of hitbox
--- @field public hitbox_h number height of hitbox
--- @class Vector
--- @field x number
--- @field y number
--- @class BoxCollider
--- @field public x number
--- @field public y number
--- @field public w number
--- @field public h number
--- @class PhysicsBody
--- @field public x number collider box x
--- @field public y number collider box y
--- @field public dx number
--- @field public dy number
--- @class BoxPhysicsBody : PhysicsBody
--- @field public collider BoxCollider the box collider
--- @class Arrow : BoxPhysicsBody
--- @field public lifetime number
--- @field public is_stuck boolean
--- @class Spring
--- @field public x number
--- @field public y number
--- @field public state number 0, 1, or 2 - from less to more expanded
--- @field public orientation number
--- @field public collider BoxCollider
--- @class Spike
--- @field public x number
--- @field public y number
--- @field public orientation number
--- @field public collider BoxCollider