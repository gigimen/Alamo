CREATE TABLE [Snoopy].[tbl_DenaroTrovato]
(
[Rap_ID] [int] NOT NULL IDENTITY(1, 1),
[Rap_NumeroRapporto] [int] NOT NULL,
[Rap_GamingDate] [datetime] NULL,
[Rap_Ora] [datetime] NULL,
[Rap_NomeCliente] [varchar] (50) COLLATE Latin1_General_CI_AS NULL,
[Rap_CognomeCliente] [varchar] (50) COLLATE Latin1_General_CI_AS NULL,
[Rap_ImportoCHF] [float] NULL,
[Rap_ImportoEuro] [float] NULL,
[Rap_NumeroCHL] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Rap_LuogoRitrovo] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Rap_Osservazioni] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Rap_Datarestituzione] [datetime] NULL,
[Rap_Datacontrollo] [datetime] NULL,
[Rap_Datatronc] [datetime] NULL,
[Rap_Denaro] [bit] NULL,
[Rap_CHL] [bit] NULL,
[Rap_Tavolo] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Rap_NoSlot] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Rap_ImportiInf] [bit] NULL,
[Rap_Descrizione] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Rap_Identificazione] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Rap-DataVersamento] [datetime] NULL,
[Rap_Ticket] [bit] NULL,
[Rap_NumeroTicket] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Rap_RapportoAnnullato] [bit] NULL,
[Rap_ChipsEuro] [bit] NULL,
[Rap_TicketEuro] [bit] NULL
) ON [PRIMARY]
GO
ALTER TABLE [Snoopy].[tbl_DenaroTrovato] ADD CONSTRAINT [PK_DenaroTrovato] PRIMARY KEY CLUSTERED  ([Rap_ID]) ON [PRIMARY]
GO
GRANT DELETE ON  [Snoopy].[tbl_DenaroTrovato] TO [FloorUsage]
GO
