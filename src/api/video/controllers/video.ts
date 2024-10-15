import { factories } from "@strapi/strapi";

export default factories.createCoreController(
  "api::video.video",
  ({ strapi }) => ({
    async like(ctx) {
      try {
        const { id } = ctx.params;
        const user = ctx.state.user;

        if (!user) {
          return ctx.forbidden("User must be logged in");
        }

        // Fetch the video with its likes
        const video: any = await strapi.documents("api::video.video").findOne({
          documentId: id,
          populate: ["likes"],
        });


        if (!video) {
          return ctx.notFound("Video not found");
        }

        // Check if the user has already liked this video
        const hasAlreadyLiked = video.likes.some((like) => like.id === user.id);
        let updatedVideo;
        if (hasAlreadyLiked) {
          // Remove the user's like

          video.updatedVideo = await strapi
            .documents("api::video.video")
            .update({
              documentId: id,
              data: {
                likes: video.likes.filter(
                  (like: { documentId: string }) =>
                    like.documentId !== user.documentId,
                ),
              },
              populate: ["likes"],
            });
        } else {
          // Add the user's like
          updatedVideo = await strapi.documents("api::video.video").update({
            documentId: id,
            populate:"likes",
            data: {
              likes: [...video.likes, user.documentId] as any,
            },
          });
        }
        return ctx.send({
          data: updatedVideo,
        });
      } catch (error) {
        return ctx.internalServerError(
          "An error occurred while processing your request",
        );
      }
    },
    async incrementView(ctx) {
      try {
        const { id } = ctx.params;
        const user = ctx.state.user;

        if (!user) {
          return ctx.forbidden("User must be logged in");
        }

        // Fetch the video with its views
        const video: any = await strapi.documents("api::video.video").findOne({
          documentId: id,
          populate: ["views", "uploader"],
        });

        if (!video) {
          return ctx.notFound("Video not found");
        }
        // Check if the user is the uploader
        if (user.id === video.uploader.id) {
          return ctx.send({
            message: "User is the uploader, no view recorded.",
          });
        }

        // Get the current views
        const currentViews =
          video.views.map((view: { documentId: string }) => view.documentId) ||
          [];
        // Check if the user has already viewed this video
        const hasAlreadyViewed = currentViews.includes(user.documentId);

        if (hasAlreadyViewed) {
          return ctx.send({ message: "User has already viewed this video." });
        }

        // Add user ID to the views array without removing existing views
        const updatedViews = [...currentViews, user.documentId];
        // Update the video with the new views array
        const updatedVideo: any = await strapi
          .documents("api::video.video")
          .update({
            documentId: id,
            data: {
              views: updatedViews as any,
            },
          });
        return ctx.send({ data: updatedVideo });
      } catch (error) {
        console.error("Error in incrementView function:", error);
        return ctx.internalServerError(
          "An error occurred while processing your request",
        );
      }
    },

    async subscribe(ctx) {
      try {
        const { id } = ctx.params; // ID of the uploader
        const user = ctx.state.user; // Logged-in user

        if (!user) {
          return ctx.forbidden("User must be logged in");
        }

        // Fetch the uploader and populate the subscribers relation
        const uploader = await strapi.db
          .query("plugin::users-permissions.user")
          .findOne({
            where: { id },
            populate: ["subscribers"],
          });

        if (!uploader) {
          return ctx.notFound("Uploader not found");
        }

        // Check if the user is already subscribed
        const isSubscribed =
          uploader.subscribers &&
          uploader.subscribers.some(
            (subscriber: { id: string }) => subscriber.id === user.id,
          );

        let updatedSubscribers;

        if (isSubscribed) {
          // If subscribed, remove the user from the subscribers array
          updatedSubscribers = uploader.subscribers.filter(
            (subscriber) => subscriber.id !== user.id,
          );
        } else {
          // If not subscribed, add the user to the subscribers array
          updatedSubscribers = [...uploader.subscribers, user.id];
        }

        // Update the uploader with the new subscribers array
        const updatedUploader = await strapi
          .query("plugin::users-permissions.user")
          .update({
            where: { id },
            data: {
              subscribers: updatedSubscribers,
            },
          });

        return ctx.send({
          message: isSubscribed
            ? "User has been unsubscribed from this uploader."
            : "User has been subscribed to this uploader.",
          data: updatedUploader,
        });
      } catch (error) {
        console.error("Error in subscribe function:", error);
        return ctx.internalServerError(
          "An error occurred while processing your request",
        );
      }
    },
  }),
);
