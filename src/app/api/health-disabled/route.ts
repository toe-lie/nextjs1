// app/api/health/route.ts
import { NextResponse } from "next/server";

export async function GET() {
  try {
    // Only test database connection in runtime, not during build
    let dbStatus = "not tested";

    if (process.env.NODE_ENV !== "development" || process.env.VERCEL !== "1") {
      try {
        const { prisma } = await import("@/lib/prisma");
        await prisma.$runCommandRaw({ ping: 1 });
        dbStatus = "connected";
      } catch (dbError) {
        dbStatus = "disconnected";
      }
    }

    return NextResponse.json({
      status: "healthy!",
      timestamp: new Date().toISOString(),
      environment: process.env.NODE_ENV,
      database: dbStatus,
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
