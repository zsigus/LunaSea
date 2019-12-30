import 'package:flutter/material.dart';
import 'package:lunasea/logic/automation/lidarr.dart';
import 'package:lunasea/pages/lidarr/subpages/catalogue/addartist/details.dart';
import 'package:lunasea/system/constants.dart';
import 'package:lunasea/system/ui.dart';

class LidarrArtistSearch extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
        return _LidarrArtistSearchWidget();
    }
}

class _LidarrArtistSearchWidget extends StatefulWidget {
    @override
    State<StatefulWidget> createState() {
        return _LidarrArtistSearchState();
    }  
}

class _LidarrArtistSearchState extends State<StatefulWidget> {
    final _scaffoldKey = GlobalKey<ScaffoldState>();
    final _searchController = TextEditingController();

    bool _searched = false;
    String _message = 'No Artists Found';
    List<LidarrSearchEntry> _entries = [];

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            key: _scaffoldKey,
            appBar: Navigation.getAppBar('Add Artist', context),
            body: _buildList(),
            floatingActionButton: _buildFloatingActionButton(),
        );
    }

    Future<void> _startSearch() async {
        if(mounted) {
            setState(() {
                _entries = [];
                _message = 'Searching...';
                _searched = true;
            });
        }
        _entries = await LidarrAPI.searchArtists(_searchController.text);
        if(mounted) {
            setState(() {
                _message = _entries == null ? 'Connection Error' : 'No Artists Found';
            });
        }
    }

    Widget _buildFloatingActionButton() {
        return FloatingActionButton(
            heroTag: null,
            tooltip: 'Search',
            child: Elements.getIcon(Icons.search),
            onPressed: () async {
                _startSearch();
            },
        );
    }

    Widget _buildList() {
        return Scrollbar(
            child: ListView.builder(
                itemCount: _entries == null || _entries.length == 0 ?  _searched ? 3 : 1 : _entries.length+2,
                itemBuilder: (context, index) {
                    switch(index) {
                        case 0: return _buildSearchBar();
                        case 1: return Elements.getDivider();
                    }
                    return _entries == null || _entries.length == 0 ?
                        Notifications.centeredMessage(_message) :
                        _buildEntry(_entries[index-2]);
                },
                padding: Elements.getListViewPadding(extraBottom: true),
            ),
        );
    }

    Widget _buildSearchBar() {
        return Card(
            child: Padding(
                child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                        labelText: 'Search...',
                        labelStyle: TextStyle(
                            color: Colors.white54,
                            decoration: TextDecoration.none,
                        ),
                        icon: Padding(
                            child: Icon(
                                Icons.search,
                                color: Color(Constants.ACCENT_COLOR),
                            ),
                            padding: EdgeInsets.fromLTRB(20.0, 8.0, 0.0, 8.0),
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 8.0),
                    ),
                    style: TextStyle(
                        color: Colors.white,
                    ),
                    cursorColor: Color(Constants.ACCENT_COLOR),
                ),
                padding: EdgeInsets.fromLTRB(0.0, 0.0, 16.0, 0.0),
            ),
            margin: Elements.getCardMargin(),
            elevation: 4.0,
        );
    }

    Widget _buildEntry(LidarrSearchEntry entry) {
        return Card(
            child: Container(
                child: ListTile(
                    title: Elements.getTitle(entry.title),
                    subtitle: Elements.getSubtitle(entry.overview, preventOverflow: true),
                    trailing: IconButton(
                        icon: Elements.getIcon(Icons.arrow_forward_ios),
                        onPressed: null,
                    ),
                    onTap: () async {
                        await _enterArtistDetails(entry);
                    },
                ),
            ),
            margin: Elements.getCardMargin(),
            elevation: 4.0,
        );
    }

    Future<void> _enterArtistDetails(LidarrSearchEntry entry) async {
        final result = await Navigator.of(context).push(
            MaterialPageRoute(
                builder: (context) => LidarrArtistSearchDetails(entry: entry),
            ),
        );
        //Handle the result
        if(result != null) {
            switch(result[0]) {
                case 'artist_added': {
                    Navigator.of(context).pop(result);
                    break;
                }
            }
        }
    }
}