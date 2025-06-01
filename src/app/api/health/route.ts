// app/api/health/route.ts
import { NextResponse } from "next/server";

export async function GET() {
  try {
    // Don't try to connect to database during build time
    if (
      process.env.NODE_ENV === "development" &&
      process.env.BUILDING === "true"
    ) {
      return NextResponse.json({
        status: "healthy (build mode)",
        timestamp: new Date().toISOString(),
        environment: process.env.NODE_ENV,
        mode: "build",
      });
    }

    // Only import Prisma at runtime, not during build
    const { prisma } = await import("@/lib/prisma");

    // Test database connection
    await prisma.$runCommandRaw({ ping: 1 });

    return NextResponse.json({
      status: "healthy!",
      timestamp: new Date().toISOString(),
      environment: process.env.NODE_ENV,
      uptime: process.uptime(),
    });
  } catch (error) {
    return NextResponse.json(
      {
        status: "unhealthy",
        error: error instanceof Error ? error.message : "Unknown error",
        timestamp: new Date().toISOString(),
      },
      { status: 500 }
    );
  }
}
