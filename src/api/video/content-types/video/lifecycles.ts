import { emitEvent, AfterCreateEvent } from "../../../../utils/emitEvent";

export default {
  async afterUpdate(event: AfterCreateEvent) {
    emitEvent("video.updated", event);
  },
  async afterCreate(event: AfterCreateEvent) {
    emitEvent("video.created", event);
  },
  async afterDelete(event: AfterCreateEvent) {
    emitEvent("video.deleted", event);
  },
};
