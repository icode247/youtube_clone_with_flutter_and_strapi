import type { Core } from "@strapi/strapi";

interface AfterCreateEvent {
  result: any;
}

function emitEvent(eventName: string, event: AfterCreateEvent) {
  const { result } = event;
  const strapi = global.strapi as Core.Strapi;

  const socketService = strapi.service("api::socket.socket");
  if (socketService && typeof (socketService as any).emit === "function") {
    (socketService as any).emit(eventName, result);
  } else {
    strapi.log.error("Socket service or emit method not found");
  }
}

export { emitEvent, AfterCreateEvent };
