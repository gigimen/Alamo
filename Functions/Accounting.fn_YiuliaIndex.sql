SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE FUNCTION [Accounting].[fn_YiuliaIndex] (
@ValueTypeID	int,
@DenoID		int
)  
RETURNS int 
AS  
BEGIN 
	declare @i int


/*
        Select Case recAlamo.Fields(2)
            Case Is = 7
                 rec1.Fields(1).Value = rec1.Fields(1).Value + recAlamo.Fields(5) * recAlamo.Fields(6) * recAlamo.Fields(7)
            Case Is = 8
                 rec1.Fields(2).Value = rec1.Fields(2).Value + recAlamo.Fields(5) * recAlamo.Fields(6) * recAlamo.Fields(7)
            Case Is = 9
                 rec1.Fields(3).Value = rec1.Fields(3).Value + recAlamo.Fields(5) * recAlamo.Fields(6) * recAlamo.Fields(7)
            Case Is = 23
                 rec1.Fields(4).Value = rec1.Fields(4).Value + recAlamo.Fields(5) * recAlamo.Fields(6) * recAlamo.Fields(7)
            Case Is = 24
                 rec1.Fields(5).Value = rec1.Fields(5).Value + recAlamo.Fields(5) * recAlamo.Fields(6) * recAlamo.Fields(7)
            Case Is = 25
                 rec1.Fields(6).Value = rec1.Fields(6).Value + recAlamo.Fields(5) * recAlamo.Fields(6) * recAlamo.Fields(7)
            Case Is = 26
                 rec1.Fields(7).Value = rec1.Fields(7).Value + recAlamo.Fields(5) * recAlamo.Fields(6) * recAlamo.Fields(7)
            Case Is = 27
                 rec1.Fields(8).Value = rec1.Fields(8).Value + recAlamo.Fields(5) * recAlamo.Fields(6) * recAlamo.Fields(7)
            Case Is = 28
                 rec1.Fields(9).Value = rec1.Fields(9).Value + recAlamo.Fields(5) * recAlamo.Fields(6) * recAlamo.Fields(7)
            Case Is = 10
                 Select Case recAlamo.Fields(1)
                    Case Is = 63, 150
                    rec1.Fields(10).Value = rec1.Fields(10).Value + recAlamo.Fields(5) * recAlamo.Fields(6) * recAlamo.Fields(7)
                    Case Is = 65
                    rec1.Fields(12).Value = rec1.Fields(12).Value + recAlamo.Fields(5) * recAlamo.Fields(6) * recAlamo.Fields(7)
                    Case Is = 64, 151
                    rec1.Fields(11).Value = rec1.Fields(11).Value + recAlamo.Fields(5) * recAlamo.Fields(6) * recAlamo.Fields(7)
            '--- JACKPOT ---
                    Case Is = 100
                    rec1.Fields(21).Value = rec1.Fields(21).Value + recAlamo.Fields(5) * recAlamo.Fields(6) * recAlamo.Fields(7)
                 End Select
            Case Is = 11
                rec1.Fields(13).Value = rec1.Fields(13).Value + recAlamo.Fields(5) * recAlamo.Fields(6) * recAlamo.Fields(7)
            
            Case Is = 20
                 rec1.Fields(15).Value = rec1.Fields(15).Value - recAlamo.Fields(5) * recAlamo.Fields(6) * recAlamo.Fields(7)
            Case Is = 29
                 rec1.Fields(16).Value = rec1.Fields(16).Value + recAlamo.Fields(5) * recAlamo.Fields(6) * recAlamo.Fields(7)
            Case Is = 18
                Select Case recAlamo.Fields(1)
                     '---- Marketing altro
                        Case Is = 71
                    rec1.Fields(17).Value = rec1.Fields(17).Value + recAlamo.Fields(5) * recAlamo.Fields(6) * recAlamo.Fields(7)
                    '---- / Lucky Tickets / ---
                        Case Is = 114
                    rec1.Fields(27).Value = rec1.Fields(27).Value + recAlamo.Fields(5) * recAlamo.Fields(6) * recAlamo.Fields(7)
                End Select


'-------/CARTE DI CREDITO/-------
           Case Is = 30
                Select Case recAlamo.Fields(1)
                    Case Is = 90
                    rec1.Fields(18).Value = rec1.Fields(18).Value + recAlamo.Fields(5) * recAlamo.Fields(6) * recAlamo.Fields(7)
                    Case Is = 98
                    rec1.Fields(20).Value = rec1.Fields(20).Value + recAlamo.Fields(5) * recAlamo.Fields(6) * recAlamo.Fields(7)
                    
                    
                 End Select
           

'------/ TRANSAZIONI AMMINISTRAZIONE  /--------
           Case Is = 19
                rec1.Fields(19).Value = rec1.Fields(19).Value + recAlamo.Fields(5) * recAlamo.Fields(6) * recAlamo.Fields(7)
                

'------/ TRANSAZIONI TITO  /-------- (deno 144, 145, 146 per tito gioco euro)
           Case Is = 31
                Select Case recAlamo.Fields(1)
                    Case Is = 102, 103, 144, 145
                rec1.Fields(22).Value = rec1.Fields(22).Value + recAlamo.Fields(5) * recAlamo.Fields(6) * recAlamo.Fields(7)
                '---- / Lucky Tickets / ---
                    Case Is = 112, 146
                rec1.Fields(28).Value = rec1.Fields(28).Value + recAlamo.Fields(5) * recAlamo.Fields(6) * recAlamo.Fields(7)
                
                 End Select
                
                
 '------/ UTILE CASSE  /-------- (valuetype id 32 per utile e flutt gioco euro e commissione CC Aduno)
           Case Is = 32
                rec1.Fields(23).Value = rec1.Fields(23).Value - recAlamo.Fields(5) * recAlamo.Fields(6) * recAlamo.Fields(7)
                
                '----- aggiunto fluttuazione gettoni euro
            'Case Is = 37
              '  rec1.Fields(23).Value = rec1.Fields(23).Value - recAlamo.Fields(5) * recAlamo.Fields(6) * recAlamo.Fields(7)
                
                
'-----/DENARO TROVATO /---------
           Case Is = 33
                rec1.Fields(24).Value = -rec1.Fields(24).Value - recAlamo.Fields(5) * recAlamo.Fields(6) * recAlamo.Fields(7)
                
                
'-----/BONIFICI /---------
           Case Is = 35
                rec1.Fields(25).Value = rec1.Fields(25).Value + recAlamo.Fields(5) * recAlamo.Fields(6) * recAlamo.Fields(7)
                
                
                
 '------/ MOVIMENTO DEPOSITI /--------
           Case Is = 22
                Select Case recAlamo.Fields(1)
                    Case Is = 77
                rec1.Fields(26).Value = rec1.Fields(26).Value + recAlamo.Fields(5) * recAlamo.Fields(6) * recAlamo.Fields(7)
                 End Select
                
                
 '------/ MOVIMENTO DEPOSITI /--------
           Case Is = 22
                Select Case recAlamo.Fields(1)
                    Case Is = 77
                rec1.Fields(26).Value = rec1.Fields(26).Value + recAlamo.Fields(5) * recAlamo.Fields(6) * recAlamo.Fields(7)
                 End Select
                 

                               

        End Select
        


*/
--select * from @xb
select @i =
case 
/*
        Select Case recAlamo.Fields(2)
            Case Is = 7
                 rec1.Fields(1).Value = rec1.Fields(1).Value + recAlamo.Fields(5) * recAlamo.Fields(6) * recAlamo.Fields(7)
            Case Is = 8
                 rec1.Fields(2).Value = rec1.Fields(2).Value + recAlamo.Fields(5) * recAlamo.Fields(6) * recAlamo.Fields(7)
            Case Is = 9
                 rec1.Fields(3).Value = rec1.Fields(3).Value + recAlamo.Fields(5) * recAlamo.Fields(6) * recAlamo.Fields(7)
            Case Is = 23
                 rec1.Fields(4).Value = rec1.Fields(4).Value + recAlamo.Fields(5) * recAlamo.Fields(6) * recAlamo.Fields(7)
            Case Is = 24
                 rec1.Fields(5).Value = rec1.Fields(5).Value + recAlamo.Fields(5) * recAlamo.Fields(6) * recAlamo.Fields(7)
            Case Is = 25
                 rec1.Fields(6).Value = rec1.Fields(6).Value + recAlamo.Fields(5) * recAlamo.Fields(6) * recAlamo.Fields(7)
            Case Is = 26
                 rec1.Fields(7).Value = rec1.Fields(7).Value + recAlamo.Fields(5) * recAlamo.Fields(6) * recAlamo.Fields(7)
            Case Is = 27
                 rec1.Fields(8).Value = rec1.Fields(8).Value + recAlamo.Fields(5) * recAlamo.Fields(6) * recAlamo.Fields(7)
            Case Is = 28
                 rec1.Fields(9).Value = rec1.Fields(9).Value + recAlamo.Fields(5) * recAlamo.Fields(6) * recAlamo.Fields(7)
*/
when @ValueTypeID = 7 then 1
when @ValueTypeID = 8 then 2
when @ValueTypeID = 9 then 3
when @ValueTypeID = 23 then 4
when @ValueTypeID = 24 then 5
when @ValueTypeID = 26 then 6
when @ValueTypeID = 27 then 8
when @ValueTypeID = 28 then 9
/*
            Case Is = 10
                 Select Case recAlamo.Fields(1)
                    Case Is = 63, 150
                    rec1.Fields(10).Value = rec1.Fields(10).Value + recAlamo.Fields(5) * recAlamo.Fields(6) * recAlamo.Fields(7)
                    Case Is = 65
                    rec1.Fields(12).Value = rec1.Fields(12).Value + recAlamo.Fields(5) * recAlamo.Fields(6) * recAlamo.Fields(7)
                    Case Is = 64, 151
                    rec1.Fields(11).Value = rec1.Fields(11).Value + recAlamo.Fields(5) * recAlamo.Fields(6) * recAlamo.Fields(7)
            '--- JACKPOT ---
                    Case Is = 100
                    rec1.Fields(21).Value = rec1.Fields(21).Value + recAlamo.Fields(5) * recAlamo.Fields(6) * recAlamo.Fields(7)
                 End Select
*/
when @ValueTypeID = 10 and @DenoID in (63,150)					then 10 
when @ValueTypeID = 10 and @DenoID = 65							then 12 
when @ValueTypeID = 10 and @DenoID in (64,151)					then 11 
when @ValueTypeID = 10 and @DenoID = 100						then 21 

/*
            Case Is = 11
                rec1.Fields(13).Value = rec1.Fields(13).Value + recAlamo.Fields(5) * recAlamo.Fields(6) * recAlamo.Fields(7)
            
            Case Is = 20
                 rec1.Fields(15).Value = rec1.Fields(15).Value - recAlamo.Fields(5) * recAlamo.Fields(6) * recAlamo.Fields(7)
            Case Is = 29
                 rec1.Fields(16).Value = rec1.Fields(16).Value + recAlamo.Fields(5) * recAlamo.Fields(6) * recAlamo.Fields(7)

*/
when @ValueTypeID = 11											then 13
when @ValueTypeID = 20											then 15
when @ValueTypeID = 29											then 16

/*

            Case Is = 18
                Select Case recAlamo.Fields(1)
                     '---- Marketing altro
                        Case Is = 71
                    rec1.Fields(17).Value = rec1.Fields(17).Value + recAlamo.Fields(5) * recAlamo.Fields(6) * recAlamo.Fields(7)
                    '---- / Lucky Tickets / ---
                        Case Is = 114
                    rec1.Fields(27).Value = rec1.Fields(27).Value + recAlamo.Fields(5) * recAlamo.Fields(6) * recAlamo.Fields(7)
                End Select

*/
when @ValueTypeID = 18 and @DenoID =71							then 17 
when @ValueTypeID = 18 and @DenoID =114							then 27 


/*
'-------/CARTE DI CREDITO/-------
           Case Is = 30
                Select Case recAlamo.Fields(1)
                    Case Is = 90
                    rec1.Fields(18).Value = rec1.Fields(18).Value + recAlamo.Fields(5) * recAlamo.Fields(6) * recAlamo.Fields(7)
                    Case Is = 98
                    rec1.Fields(20).Value = rec1.Fields(20).Value + recAlamo.Fields(5) * recAlamo.Fields(6) * recAlamo.Fields(7)
                    
                    
                 End Select

*/
when @ValueTypeID = 30 and @DenoID =90							then 18 
when @ValueTypeID = 30 and @DenoID =98							then 20 


/*
'------/ TRANSAZIONI AMMINISTRAZIONE  /--------
           Case Is = 19
                rec1.Fields(19).Value = rec1.Fields(19).Value + recAlamo.Fields(5) * recAlamo.Fields(6) * recAlamo.Fields(7)
*/
when @ValueTypeID = 19											then 19


/*
'------/ TRANSAZIONI TITO  /-------- (deno 144, 145, 146 per tito gioco euro)
           Case Is = 31
                Select Case recAlamo.Fields(1)
                    Case Is = 102, 103, 144, 145
                rec1.Fields(22).Value = rec1.Fields(22).Value + recAlamo.Fields(5) * recAlamo.Fields(6) * recAlamo.Fields(7)
                '---- / Lucky Tickets / ---
                    Case Is = 112, 146
                rec1.Fields(28).Value = rec1.Fields(28).Value + recAlamo.Fields(5) * recAlamo.Fields(6) * recAlamo.Fields(7)
                
                 End Select
*/
when @ValueTypeID = 31 and @DenoID in (102, 103, 140, 141)		then 22 
--corretto in 115 2 148 perché prendiamo il dato scritto dalla cassiera e non quello letto al terminale
when @ValueTypeID = 31 and @DenoID in (115, 148)				then 28 

/*
                
 '------/ UTILE CASSE  /-------- (valuetype id 32 per utile e flutt gioco euro e commissione CC Aduno)
           Case Is = 32
                rec1.Fields(23).Value = rec1.Fields(23).Value - recAlamo.Fields(5) * recAlamo.Fields(6) * recAlamo.Fields(7)
                
                '----- aggiunto fluttuazione gettoni euro
            'Case Is = 37
              '  rec1.Fields(23).Value = rec1.Fields(23).Value - recAlamo.Fields(5) * recAlamo.Fields(6) * recAlamo.Fields(7)

*/

when @ValueTypeID = 32 and @DenoID = 104						then 23 --utile cambio per vendita euro
when @ValueTypeID = 32 and @DenoID = 152						then 29 --utile cambio per vendita euro

/*
'-----/DENARO TROVATO /---------
           Case Is = 33
                rec1.Fields(24).Value = -rec1.Fields(24).Value - recAlamo.Fields(5) * recAlamo.Fields(6) * recAlamo.Fields(7)
*/
when @ValueTypeID = 33											then 24

/*
                
'-----/BONIFICI /---------
           Case Is = 35
                rec1.Fields(25).Value = rec1.Fields(25).Value + recAlamo.Fields(5) * recAlamo.Fields(6) * recAlamo.Fields(7)
                
*/
when @ValueTypeID = 35											then 25

/*
                
 '------/ MOVIMENTO DEPOSITI /--------
           Case Is = 22
                Select Case recAlamo.Fields(1)
                    Case Is = 77
                rec1.Fields(26).Value = rec1.Fields(26).Value + recAlamo.Fields(5) * recAlamo.Fields(6) * recAlamo.Fields(7)
                 End Select
                
                
 '------/ MOVIMENTO DEPOSITI /--------
           Case Is = 22
                Select Case recAlamo.Fields(1)
                    Case Is = 77
                rec1.Fields(26).Value = rec1.Fields(26).Value + recAlamo.Fields(5) * recAlamo.Fields(6) * recAlamo.Fields(7)
                 End Select
*/
when @ValueTypeID = 22 and @DenoID = 77							then 26

end

	return @i
END





GO
