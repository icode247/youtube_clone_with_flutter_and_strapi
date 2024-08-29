import { emitEvent, AfterCreateEvent } from "../../../../utils/emitEvent";

export default {
  async afterCreate(event: AfterCreateEvent) {
    emitEvent("comment.created", event);
  },

  async afterUpdate(event: AfterCreateEvent) {
    emitEvent("comment.updated", event);
  },

  async afterDelete(event: AfterCreateEvent) {
    emitEvent("comment.deleted", event);
  },
};
