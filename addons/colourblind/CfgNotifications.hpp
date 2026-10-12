// Notification status colours. Every reopened class restates its parent.

class CfgNotifications {
    class TaskAssigned;
    class TaskCreatedIcon;
    class TaskSucceeded: TaskAssigned {
        color[] = {"(profilenamespace getvariable ['A3ACC_Surf_CfgNotifications_TaskSucceeded_color_R',0.7])","(profilenamespace getvariable ['A3ACC_Surf_CfgNotifications_TaskSucceeded_color_G',1])","(profilenamespace getvariable ['A3ACC_Surf_CfgNotifications_TaskSucceeded_color_B',0.3])",1};
    };
    class TaskFailed: TaskAssigned {
        color[] = {"(profilenamespace getvariable ['A3ACC_Surf_CfgNotifications_TaskFailed_color_R',1])","(profilenamespace getvariable ['A3ACC_Surf_CfgNotifications_TaskFailed_color_G',0.3])","(profilenamespace getvariable ['A3ACC_Surf_CfgNotifications_TaskFailed_color_B',0.2])",1};
    };
    class TaskCanceled: TaskAssigned {
        color[] = {"(profilenamespace getvariable ['A3ACC_Surf_CfgNotifications_TaskCanceled_color_R',0.7])","(profilenamespace getvariable ['A3ACC_Surf_CfgNotifications_TaskCanceled_color_G',0.7])","(profilenamespace getvariable ['A3ACC_Surf_CfgNotifications_TaskCanceled_color_B',0.7])",1};
    };
    class TaskAssignedIcon: TaskCreatedIcon {
        colorIconPicture[] = {"(profilenamespace getvariable ['A3ACC_Surf_CfgNotifications_TaskAssignedIcon_colorIconPicture_R',1])","(profilenamespace getvariable ['A3ACC_Surf_CfgNotifications_TaskAssignedIcon_colorIconPicture_G',0.7])","(profilenamespace getvariable ['A3ACC_Surf_CfgNotifications_TaskAssignedIcon_colorIconPicture_B',0])",1};
    };
    class TaskSucceededIcon: TaskCreatedIcon {
        color[] = {"(profilenamespace getvariable ['A3ACC_Surf_CfgNotifications_TaskSucceededIcon_color_R',0.7])","(profilenamespace getvariable ['A3ACC_Surf_CfgNotifications_TaskSucceededIcon_color_G',1])","(profilenamespace getvariable ['A3ACC_Surf_CfgNotifications_TaskSucceededIcon_color_B',0.3])",1};
        colorIconPicture[] = {"(profilenamespace getvariable ['A3ACC_Surf_CfgNotifications_TaskSucceededIcon_colorIconPicture_R',0.7])","(profilenamespace getvariable ['A3ACC_Surf_CfgNotifications_TaskSucceededIcon_colorIconPicture_G',1])","(profilenamespace getvariable ['A3ACC_Surf_CfgNotifications_TaskSucceededIcon_colorIconPicture_B',0.3])",1};
    };
    class TaskFailedIcon: TaskCreatedIcon {
        color[] = {"(profilenamespace getvariable ['A3ACC_Surf_CfgNotifications_TaskFailedIcon_color_R',1])","(profilenamespace getvariable ['A3ACC_Surf_CfgNotifications_TaskFailedIcon_color_G',0.3])","(profilenamespace getvariable ['A3ACC_Surf_CfgNotifications_TaskFailedIcon_color_B',0.2])",1};
        colorIconPicture[] = {"(profilenamespace getvariable ['A3ACC_Surf_CfgNotifications_TaskFailedIcon_colorIconPicture_R',1])","(profilenamespace getvariable ['A3ACC_Surf_CfgNotifications_TaskFailedIcon_colorIconPicture_G',0.3])","(profilenamespace getvariable ['A3ACC_Surf_CfgNotifications_TaskFailedIcon_colorIconPicture_B',0.2])",1};
    };
    class TaskCanceledIcon: TaskCreatedIcon {
        color[] = {"(profilenamespace getvariable ['A3ACC_Surf_CfgNotifications_TaskCanceledIcon_color_R',0.7])","(profilenamespace getvariable ['A3ACC_Surf_CfgNotifications_TaskCanceledIcon_color_G',0.7])","(profilenamespace getvariable ['A3ACC_Surf_CfgNotifications_TaskCanceledIcon_color_B',0.7])",1};
        colorIconPicture[] = {"(profilenamespace getvariable ['A3ACC_Surf_CfgNotifications_TaskCanceledIcon_colorIconPicture_R',0.7])","(profilenamespace getvariable ['A3ACC_Surf_CfgNotifications_TaskCanceledIcon_colorIconPicture_G',0.7])","(profilenamespace getvariable ['A3ACC_Surf_CfgNotifications_TaskCanceledIcon_colorIconPicture_B',0.7])",1};
    };
    class ScoreAdded {
        color[] = {"(profilenamespace getvariable ['A3ACC_Surf_CfgNotifications_ScoreAdded_color_R',0.5])","(profilenamespace getvariable ['A3ACC_Surf_CfgNotifications_ScoreAdded_color_G',1])","(profilenamespace getvariable ['A3ACC_Surf_CfgNotifications_ScoreAdded_color_B',1])",1};
    };
};
