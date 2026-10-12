// Notification status colours, on the same universal palette as CfgInGameUI.
// Vanilla success is green and failure is red, the protan and deutan confusion
// pair, in the corner of the screen where a player is least able to read it
// twice. The parents are restated so a bare reopen cannot clear them.

class CfgNotifications {
    class TaskAssigned;
    class TaskCreatedIcon;
    class TaskSucceeded: TaskAssigned {
        color[] = {0.00, 0.80, 0.80, 1};
    };
    class TaskFailed: TaskAssigned {
        color[] = {1.00, 0.70, 0.00, 1};
    };
    class TaskCanceled: TaskAssigned {
        color[] = {0.75, 0.75, 0.75, 1};
    };
    class TaskAssignedIcon: TaskCreatedIcon {
        colorIconPicture[] = {1.00, 0.70, 0.00, 1};
    };
    class TaskSucceededIcon: TaskCreatedIcon {
        color[] = {0.00, 0.80, 0.80, 1};
        colorIconPicture[] = {0.00, 0.80, 0.80, 1};
    };
    class TaskFailedIcon: TaskCreatedIcon {
        color[] = {1.00, 0.70, 0.00, 1};
        colorIconPicture[] = {1.00, 0.70, 0.00, 1};
    };
    class TaskCanceledIcon: TaskCreatedIcon {
        color[] = {0.75, 0.75, 0.75, 1};
        colorIconPicture[] = {0.75, 0.75, 0.75, 1};
    };
    class ScoreAdded {
        color[] = {0.00, 0.80, 0.80, 1};
    };
};
