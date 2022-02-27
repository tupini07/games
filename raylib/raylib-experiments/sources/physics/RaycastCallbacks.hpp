#pragma once

#include <box2d/box2d.h>

class RaysCastGetNearestCallback : public b2RayCastCallback
{
public:
    RaysCastGetNearestCallback() : m_fixture(NULL)
    {
    }

    float ReportFixture(b2Fixture *fixture, const b2Vec2 &point, const b2Vec2 &normal, float fraction)
    {
        m_fixture = fixture;
        m_point = point;
        m_normal = normal;
        m_fraction = fraction;
        return fraction;
    }

    b2Fixture *m_fixture;
    b2Vec2 m_point;
    b2Vec2 m_normal;
    float m_fraction;
};