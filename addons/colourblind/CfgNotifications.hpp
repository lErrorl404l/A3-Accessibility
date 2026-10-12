// Notification status colours, on the same universal palette as CfgInGameUI.
// Vanilla success is green and failure is red, which is the protan and deutan
// confusion pair in the corner of the screen where a player is least able to
// read it twice.

class CfgNotifications {
    class TaskSucceeded {
        color[] = {0.00, 0.80, 0.80, 1};
    };
    class TaskFailed {
        color[] = {1.00, 0.70, 0.00, 1};
    };
    class TaskCanceled {
        color[] = {0.75, 0.75, 0.75, 1};
    };
    class TaskAssignedIcon {
        colorIconPicture[] = {1.00, 0.70, 0.00, 1};
    };
    class TaskSucceededIcon {
        color[] = {0.00, 0.80, 0.80, 1};
        colorIconPicture[] = {0.00, 0.80, 0.80, 1};
    };
    class TaskFailedIcon {
        color[] = {1.00, 0.70, 0.00, 1};
        colorIconPicture[] = {1.00, 0.70, 0.00, 1};
    };
    class TaskCanceledIcon {
        color[] = {0.75, 0.75, 0.75, 1};
        colorIconPicture[] = {0.75, 0.75, 0.75, 1};
    };
    class ScoreAdded {
        color[] = {0.00, 0.80, 0.80, 1};
    };
};
