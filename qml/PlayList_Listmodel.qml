import QtQuick 2.15

ListView{
    id:listview
    x:0;y:100
    width: 200
    height:700
    clip: true
    model: ListModel{
        ListElement{img:"./heart.png" ;label:"我喜欢的"; playlistId:1}
        ListElement{img:"./heart-break.png" ;label:"我不喜欢的"; playlistId:2}
        ListElement{img:"./handband.png" ;label:"许愿十二点之前睡着"; playlistId:3}
        ListElement{img:"./nation_1.png" ;label:"ta喜欢的"; playlistId:4}
        ListElement{img:"./nation_2.png" ;label:"ta很喜欢的"; playlistId:5}
        ListElement{img:"./clown.png" ;label:"ta狠狠喜欢的"; playlistId:6}
        ListElement{img:"./demon.png" ;label:"你和我喜欢的"; playlistId:7}
        ListElement{img:"./paper_plane.png" ;label:"ta和我喜欢的"; playlistId:8}
        ListElement{img:"./heart.png" ;label:"你我都不喜欢的"; playlistId:9}
        ListElement{img:"./heart.png" ;label:"你喜欢的"; playlistId:10}
    }

    delegate: PlayList{}
}