import { PrismaClient } from "./generated/prisma";

const prisma = new PrismaClient();

async function main() {
  //   await prisma.user.create({
  //     data: {
  //       name: "John Doe",
  //       email: "hello@prisma.com",
  //       posts: {
  //         create: {
  //           title: "My first post",
  //           body: "Lots of really interesting stuff",
  //           slug: "my-first-post",
  //         },
  //       },
  //     },
  //   });
  //const allUsers: User[] = await prisma.user.findMany({});
  //console.dir(allUsers, { depth: null });

  await prisma.post.update({
    where: {
      slug: "my-first-post",
    },
    data: {
      comments: {
        createMany: {
          data: [
            { comment: "Great post!" },
            { comment: "Can't wait to read more!" },
          ],
        },
      },
    },
  });
  const posts = await prisma.post.findMany({
    include: {
      comments: true,
    },
  });
  console.dir(posts, { depth: Infinity });
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
