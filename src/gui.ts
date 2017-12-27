import * as m from "mithril";
import {Stream} from "mithril/stream";
import s from "mithril/stream";

import "./reset.css";
import "./style.css";
import "./startup.css";

interface GroupData {
  name: string,
  icon: string,
  url: string
}

function AddGroup() {
  return {
    view: function() {
      return m("#add-groups");
    }
  }
}

function Group(focusedGroup: Stream<any>, data: GroupData) {
  var group = {
    chat: function() {
      return {
        view: function() {
          return m(".chat",
            m("webview", {
              src: data.url,
              style: {
                visibility: group == focusedGroup() ? "visible" : "hidden"
              }
            })
          );
        }
      }
    },
    icon: function() {
      return {
        view: function() {
          return m("img.group-icon", {
            src: data.icon,
            onclick: () => focusedGroup(group)
          })
        }
      }
    }
  }
  return group;
}

function UserSettings() {
  var name = "";
  return {
    view: function () {
      return m("#user-settings",
          m("form#settings", [
          m("p", "Name"),
          m("input#name", {
            oninput: m.withAttr("value", (value) => name = value),
            onkeypress: (e: KeyboardEvent ) => { if (e.key == "Enter") localStorage.name = name }
          })
        ]
      ));
    }
  }
}

function Chats(groups: any[]) {
  return {
    view: function() {
      return m("#grid-wrapper", [
        m("#groups", groups.map(group => m(group.icon))),
        m(AddGroup),
        groups.map(group => m(group.chat)),
      ]);
    }
  }
}

function App() {
  var focusedGroup = s<any>();
  var groups = [
    Group(focusedGroup, {
      name: "Bro Council",
      icon: "https://imgur.com/ZtDciSc.png",
      url: "http://google.com"
    })
  ];
  focusedGroup(groups[0]);

  return {
    view: function() {
      if (localStorage.name != null) {
        return m(Chats(groups));
      } else {
        return m(UserSettings);
      }
    }
  };
}

m.mount(document.body, App);
